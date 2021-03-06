require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'

def antivirus_scan(dir)
  Ddr::Antivirus.scanner_adapter = :clamd
  result = Ddr::Antivirus.scan dir 
end

def generate_filelist(dir, file_list)
  begin
    if File.directory?(dir)
      DirToXml.dir2list(dir, file_list)
    else 
      raise 'Invalid Directory'
    end
  rescue Exception => e
    puts "Error in generating list of files"
    puts e.message
    logger.error e.message
    logger.error e.backtrace.inspect
  end
end

def create_bag(target_dir, files, full_path)
  bag = BagIt::Bag.new target_dir
  files.each do |f|
    File.open(f) do |rio|
      if full_path
        file_path = f.gsub!(/[^0-9A-Za-z.\-]/, '_')
      else
        file_path = File.basename(f)
      end
        begin
          bag.add_file(file_path) {|io| io.write rio.read }
        rescue Exception => e
          cleanup(target_dir)
          retry
       end
    end
  end
  bag.manifest!
end

def validate_bag(dir)
  bag = BagIt::Bag.new dir
  return bag.valid?
end

def mysql_query(connection,query)
  begin 
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end

def ingest_files(issue_path, saved_location, file_type)
  target_dir = File.join(saved_location, file_type.upcase)
  FileUtils::mkdir_p target_dir
  issue = issue_path.split("/").last
  case file_type 
  when "pdf", "jp2"
    files = Dir.glob(issue_path+"/**/*."+file_type.downcase)
  when "tiff"
    files = Dir.glob(issue_path+"**/*.tif")
  when "alto"
    files = Dir.glob(issue_path+'**/*').grep(/\/\d\d\d\d\.xml/)
  when "mets"
    files = Dir.glob(issue_path+"/**/articles_*.xml") + Dir.glob(issue_path + "/**/" + issue + "*.xml")
  end
  create_bag(target_dir, files, false)
  Utils.tar(File.join(saved_location, "#{file_type.downcase}.tar"), "#{target_dir}")
end

def cleanup(dir)
  FileUtils.rm_rf(dir)
end

def newspaper(opts, mysql_connection)
  dir = opts[:directory]
  puts dir
  publication = opts[:publication]
  delivery = opts[:delivery]
  drive_id = opts[:drive]
  dryrun = opts[:dryrun]
  Dir.glob("#{dir}/**/articles*.xml") do |f|
    puts f
    issue_path = File.dirname(f)
    issue = issue_path.split("/").last
    puts issue
    logger.error "invalid issue format" if issue !~ /^[0-9]{8,10}/ 
    pagecount = Dir.glob("#{issue_path}/**/*.jp2").count
    year = issue.split("_").last.split(//).first(4).join
    date = issue.split("_").last.split(//).first(8).last(2).join.sub(/^0/,"")
    month = issue.split("_").last.split(//).first(6).last(2).join.sub(/^0/,"")
    edition = issue.split("_").last.split(//).last(2).join.sub(/^0/,"")
    select = "SELECT noid from newspapers where newspaper = '#{publication}' AND year = '#{year}' AND month = '#{month}' and day = '#{date}' and edition = '#{edition}'"
    puts select
    result = mysql_query(mysql_connection, select)
    noid = ''
    result.each do |row|
      noid = row.first
    end
    if result.num_rows == 0 
      insert = "INSERT INTO newspapers(newspaper, year, month, day, edition, pages, delivery, delivery_disk, delivery_date) VALUES
       ('#{publication}', #{year}, #{month}, #{date}, #{edition}, #{pagecount}, '#{delivery}', '#{drive_id}', NOW())"
      puts insert
      mysql_query(mysql_connection, insert) unless dryrun
      properties = Helpers.read_properties('properties.yml')
      temp_dir = properties['temp_dir']
      temp_location = File.join(temp_dir, issue)
      ingest_files(issue_path, temp_location, 'jp2') if Dir.glob("#{issue_path}/**/*.jp2").count > 0
      ingest_files(issue_path, temp_location, 'tiff') if Dir.glob("#{issue_path}/**/*.tif").count > 0
      ingest_files(issue_path, temp_location, 'alto')
      ingest_files(issue_path, temp_location, 'mets')
      ingest_files(issue_path, temp_location, 'pdf')
      noid = Utils.noid
      metadata = {"publication" => publication, "year"=> year, "month" => month, "date" => date, "noid" => noid }
      Dir.glob("#{temp_location}/*.*") do |f|
        Openstack.ingest_newspaper(f,metadata)
      end
      update = "UPDATE newspapers set noid = '#{noid}' where newspaper = '#{publication}' and year = '#{year}' and month = '#{month}' and day = '#{date}'"
      mysql_query(mysql_connection, update) unless dryrun
      cleanup(temp_location)
    else
      puts "There is a duplicated record in the database: check #{issue_path}"
    end
  end
end

def peel(opts, mysql_connection)
  dir = opts[:directory]
  puts dir
  delivery = opts[:delivery]
  drive_id = opts[:drive]
  dryrun = opts[:dryrun]
  Dir.glob("#{dir}/**/*-METS.xml") do |f|
    puts f
    item_mets = File.basename(f)
    item_path = File.dirname(f)
    item = item_mets.split("-METS").first
    puts item
    #normalize P number to handle cases like 3021.12, instead of P003021.12
    if !item.match(/^(N|P)(\d+)\.*.*/)
      logger.info "The item name is not normalized"
      number = item.match(/^(\d+)(\.*.*)/i)
      one, two = number.captures
      one = "%06d" % one.to_i
      item = "P" + one + two
      puts item
    end
    pagecount = Dir.glob("#{dir}/**/*.jp2").count
    insert = "INSERT INTO items(code, digstatus, delivery, scanimages) VALUES ('#{item}', 'digitized', '#{delivery}', '#{pagecount}')
              ON DUPLICATE KEY UPDATE code = VALUES(code), digstatus=VALUES(digstatus), delivery=VALUES(delivery), scanimages=VALUES(scanimages)"
    puts insert
    result = mysql_query(mysql_connection, select)  
    
    temp_location = File.join(temp_dir, item)
    puts temp_location
    ingest_files(item_path, temp_location, 'jp2') if Dir.glob("#{item_path}/**/*.jp2").count > 0 
    ingest_files(item_path, temp_location, 'tiff') if Dir.glob("#{item_path}/**/*.tif").count > 0
    ingest_files(item_path, temp_location, 'alto')
    ingest_files(item_path, temp_location, 'mets')
    ingest_files(item_path, temp_location, 'pdf')
    logger.info "Ready to ingest #{item} into OpenStack"
    noid = Utils.noid
    metadata = {"noid" => noid, "peelnum" => item }
    Dir.glob("#{temp_location}/*.*") do |f|
      Openstack.ingest_peelbib(f, metadata)
    end
    update = "UPDATE items set noid = '#{noid}' where code = '#{item}'"
    mysql_query(mysql_connection, update) unless dryrun
    cleanup(temp_location)
  end
end

def generic(opts, mysql_connection)

  dir = opts[:directory]
  puts dir
  delivery = opts[:delivery]
  dryrun = opts[:dryrun]
  collection = opts[:collection]
  Dir.glob("#{dir}/*") do |d|
    object = File.basename(d)
    normalized_object = object.gsub!(/[^0-9A-Za-z.\-]/, '_')
    puts normalized_object 
    if result.num_rows == 0
      insert = "INSERT INTO digitization_noids(object_name, collection, delivery) VALUES ('#{normalized_object}', '#{collection}', '#{delivery}')"
      puts insert
      mysql_query(mysql_connection, insert) unless dryrun
      properties = load_properties
      temp_dir = properties['temp_dir']
      target_dir = File.join(temp_dir, normalized_object)
      create_bag(target_dir, Dir[d], false)
      temp_location = temp_dir + "/" + normalized_object + "_tar"
      Utils.tar(File.join(temp_location, '1.tar'), "#{target_dir}")
      noid = Utils.noid
      metadata = {"noid"=> noid, "collection"=>collection, "file_name"=>normalized_object}
      Openstack.ingest_generic("#{temp_location}/1.tar", metadata)
      update = "UPDATE digitization_noids set noid = '#{noid}' where object_name = '#{normalized_object}'"
      puts update
      mysql_query(mysql_connection, update) unless dryrun
      cleanup(temp_location)
    else
      puts "There is a duplicated record in the database: check #{issue_path}"
    end
  end
end


# This script is to ingest any given folder with digitized materials into OpenStack
  opts = Slop.parse do |o|
    o.string '-t', '--resource-type', 'Type of resource is to be ingested (peelbib,newspaper, image, steele, other)'
    o.bool '-dry', '--dry-run', 'Dry run of the ingest'
    o.string '-d', '--directory', 'Directory that need to be ingested'
    o.string '-l', '--file-list', 'File name of the file list output'
    o.string '-delivery', '--delivery', 'Delivery number that this ingest batch will be logged in the database'
    o.string '-drive', '--drive-id', 'last four digits of the hard drive ID this delivery is on'
    o.string '-p', '--publication', 'Three digit publication code for newspaper and magazine'
    o.string '-c', '--collection', 'Collection name that this ingest batch belongs to'
    o.bool '-b', '--skipbag', 'Skip checking if the delivery is a valid bag'
  end

  puts opts.to_hash
  timestamp = Time.now.to_s.tr(" ", "_")
  dir = opts[:directory]
  file_list = opts[:file_list]
  last_dir = dir.split("/").last
  type = opts[:resource_type]
  dryrun = opts[:dry_run]
  collection = opts[:collection]
  skip_bag = opts[:skipbag]
  logfile = "log/ingest-#{last_dir}-#{timestamp}"
  logger = Logger.new(logfile)
  logger.info "Start Ingest the directory #{dir}"
  #Virus Scanning
  logger.info "Start scanning the directory for virus"
  scan_result = antivirus_scan(dir) 
  logger.info "Virus scanning completed, at #{result.scanned_at}"
  logger.info scan_result.to_s
  #Generating filelist
  logger.info "Generating list of files within the directory #{dir}"
  generate_filelist(dir, file_list)
  valid = DirToXml.validation(dir, file_list)
  logger.info "Successfully generated a file list at #{file_list}" if valid
  logger.error "Error when creating file list for #{dir}" if !valid
  #Validate bag
  unless skip_bag 
    logger.info "Start to valid bags in the delivery"
    bagcount = Dir.glob(dir+"/**/bagit.txt").count
    logger.info "Validate #{bagcount} bag directories in the delivery"
    validate_bag(dir)
    Dir.glob(dir+"/**/bagit.txt") do |f|
      d = File.dirname(f)
      bag_valid = validate_bag(d)
      if bag_valid
        logger.info "Directory #{d} is a valid bag" 
        FileUtils.touch (d +'/bag_verified')
      else 
        logger.error "Directory #{d} is not a valid bag, view log files for more detailed information"
        FileUtils.touch (d+'/bag_not_verified')
      end
    end
  end
  #Checkin to the database
  logger.info "Checkin the delivery into the tracking database"
  connection = Helpers.set_mysql_connection
  if type == "newspaper"
    newspaper(opts, connection)
  elsif type == "peelbib"
    peelbib(opts)
  elsif type == "steele"
    steele(opts)
  elsif type == "generic"
    generic(opts, connection)
  end
  Helpers.close_mysql_connection(connection)
