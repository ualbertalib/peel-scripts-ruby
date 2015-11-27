require 'slop'
require './helpers'
require 'ddr-antivirus'

# This script is to ingest any given folder with digitized materials into OpenStack
  opts = Slop.parse do |o|
    o.string '-t', '--resource-type', 'Type of resource is to be ingested (peelbib,newspaper, image, steele, other)'
    o.bool '-dry', '--dry-run', 'Dry run of the ingest'
    o.string '-d', '--directory', 'Directory that need to be ingested'
    o.string '-l', '--file-list', 'File name of the file list output'
    o.string '-delivery', '--delivery', 'Delivery number that this ingest batch will be logged in the database'
    o.string '-drive', '--drive-id', 'last four digits of the hard drive ID this delivery is on'
    o.string '-p', '--publication', 'Three digit publication code for newspaper and magazine'
  end

  puts opts.to_hash
  #generate a list of files with size and md5 hashes
  timestamp = Time.now.to_s.tr(" ", "_")
  dir = opts[:directory]
  file_list = opts[:file_list]
  last_dir = dir.split("/").last
  publication = opts[:publication]
  type = opts[:resource_type]
  dryrun = opts[:dry_run]
  delivery = opts[:delivery]
  drive_id = opts[:drive_id]
  
  logfile = "log/ingest-#{last_dir}-#{timestamp}"
  logger = Logger.new(logfile)
  logger.info "Start Ingest the directory #{dir}"
  logger.info "Start scanning the directory for virus"

  Ddr::Antivirus.scanner_adapter = :clamd
  result = Ddr::Antivirus.scan dir

  logger.info "Virus scanning completed, at #{result.scanned_at}"
  logger.info result.to_s
 
  logger.info "Generating list of files within the directory #{dir}"
 
  begin
    if File.directory?(dir)
      DirToXml.dir2list(dir, file_list) if File.directory?(dir)
    else 
      raise 'Invalid Directory'
    end
  rescue Exception => e
    puts "Error in generating list of files"
    puts e.message
    logger.error e.message
    logger.error e.backtrace.inspect
  end
  valid = DirToXml.validation(dir, file_list)
  logger.info "Successfully generated a file list at #{file_list}" if valid
  logger.error "Error when creating file list for #{dir}" if !valid

  logger.info "Start to valid bags in the delivery"

  bagcount = Dir.glob(dir+"/**/bagit.txt").count

  logger.info "Validate #{bagcount} bag directories in the delivery"
  Dir.glob(dir+"/**/bag*") do |f|
    next unless File.exist?(f)
    d = File.dirname(f)
    valid_bag = Bag.bagit_verify(d)
    logger.info "Directory #{d} is a valid bag" if valid_bag
    logger.error "Directory #{d} is not a valid bag, view log files for more detailed information" if !valid_bag
  end

  logger.info "Checkin the delivery into the tracking database"

  database_config = YAML.load_file('database.yml')
  username = database_config[:username]
  password = database_config[:password]
  database = database_config[:database]
  hostname = database_config[:hostname]

  connection = Mysql.new(hostname, username, password, database)

  if type == "newspaper"

    Dir.glob("#{dir}/**/data/#{publication}*") do |d|
      item = File.basename(d)
      pagecount = Dir.glob("#{d}/**/*.jp2").count
      delivery_date = Time.now
      year = item.split("_").last.split(//).first(4).join
      month = item.split("_").last.split(//).last(4).first(2).join
      date = item.split("_").last.split(//).last(2).join
      insert = "INSERT INTO newspapers_copy(newspaper, year, month, day, pages, delivery, delivery_disk, delivery_date) VALUES
	(#{publication}, #{year}, #{month}, #{date}, #{pagecount}, #{delivery}, #{drive_id}, #{delivery_date})"
      rs = connection.query(insert)
    end
  end
  connection.close
    
    

