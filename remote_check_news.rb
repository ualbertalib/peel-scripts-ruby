require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'
require 'net/sftp'
require 'optparse'
require 'nokogiri'


def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end


# opts = Slop.parse do |o|
#   o.string '-t', '--resource-type', 'Type of resource is to be ingested (peelbib,newspaper, image, steele, other)'
#   o.bool '-dry', '--dry-run', 'Dry run of the ingest'
#   o.string '-d', '--directory', 'Directory that need to be ingested'
#   o.string '-l', '--file-list', 'File name of the file list output'
#   o.string '-delivery', '--delivery', 'Delivery number that this ingest batch will be logged in the database'
#   o.string '-drive', '--drive-id', 'last four digits of the hard drive ID this delivery is on'
#   o.string '-p', '--publication', 'Three digit publication code for newspaper and magazine'
#   o.string '-c', '--collection', 'Collection name that this ingest batch belongs to'
#   o.bool '-b', '--skipbag', 'Skip checking if the delivery is a valid bag'
# end
# puts opts.to_hash
# timestamp = Time.now.to_s.tr(" ", "_")
# dir = opts[:directory]
# file_list = opts[:file_list]
# last_dir = dir.split("/").last
# type = opts[:resource_type]
# dryrun = opts[:dry_run]
# collection = opts[:collection]
# skip_bag = opts[:skipbag]
t1 = Time.now
options = {}
OptionParser.new do |opts|
  opts.on("-t", "--resource-type TYPE", "Type of resource is to be ingested (peelbib,newspaper, image, steele, other)") do |v|
    options[:resource_type] = v
  end
  opts.on("-r", "--[no-]dry-run", "Dry run of the ingest") do |v|
    options[:dry_run] = v
  end
  opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
  opts.on("-l", "--file-list LIST", "File name of the file list output") do |v|
    options[:file_list] = v
  end
  opts.on("-d", "--delivery DELIVERY", "Delivery number that this ingest batch will be logged in the database") do |v|
    options[:delivery] = v
  end
  opts.on("-i", "--drive-id ID", "last four digits of the hard drive ID this delivery is on") do |v|
    options[:drive_id] = v
  end
  opts.on("-p", "--publication PUB", "Three digit publication code for newspaper and magazine") do |v|
    options[:publication] = v
  end
  opts.on("-c", "--collection COLL", "Collection name that this ingest batch belongs to") do |v|
    options[:collection] = v
  end
  opts.on("-b", "--[no-]skipbag", "Skip checking if the delivery is a valid bag") do |v|
    options[:skipbag] = v
  end
end.parse!
p options
timestamp = Time.now.to_s.tr(" ", "_")
dir = options[:directory]
file_list = options[:file_list]
#last_dir = dir.split("/").last
type = options[:resource_type]
dryrun = options[:dry_run]
collection = options[:collection]
skip_bag = options[:skipbag]
#logfile = "log/remote-#{last_dir}-#{timestamp}"
#logger = Logger.new(logfile)
#logger.info "Start check if upload Successfully"
#check if tar file changes
connection = Helpers.set_mysql_connection
Dir.glob("/diginit/work/upload/gat/**/insert.txt") do |f|
  puts f
  tar_path = File.dirname(f)
  # folder = tar_path.split("/").last
  # puts folder
  # DirToXml.md5remote(tar_path)
  # file1 = File.join(tar_path,'tarlist.xml')
  # file2 = File.join(tar_path,'tarlist2.xml')
  # doc1 = Nokogiri::XML(File.open(file1))
  # doc2 = Nokogiri::XML(File.open(file2))
  # checksum1 = doc1.xpath("//md5/text()")
  # checksum2 = doc2.xpath("//md5/text()")
  #
  # if checksum1==checksum2
  #   puts "#{folder}: file transfer correct"
  #   #logger.info "#{folder}: file transfer correct"
  # else
  #   puts "#{folder}: file transfer error"
  #   #logger.error "#{folder}: file transfer error"
  # end
  #check if it exsit in database
  File.open(File.join(tar_path,'select.txt')).each do |line|
    puts line
    rs = mysql_query(connection, line)
    puts "result for selection#{rs}"
    sum=0
    #puts"here is #{sum}"
    rs.each do |row|
      puts row
      sum=sum+1
      puts "sum is #{sum}"
      end
      if sum==0
        File.open(File.join(tar_path,'insert.txt')).each do |line|
          puts line
          result = mysql_query(connection, line) unless dryrun
          puts "insert result #{result}"
        end
        puts "finish insert into the database"
        #push to openstack
        metadata=File.open(File.join(tar_path,"metadata.marshal"), "r"){|from_file| Marshal.load(from_file)}
        puts metadata
        if type == "newspaper"
          Dir.glob("#{tar_path}/*.{tar,pdf}*") do |f|
            Openstack.ingest_newspaper(f,metadata)
          end
        elsif type == "peelbib"
          Dir.glob("#{tar_path}/*.tar") do |f|
            Openstack.ingest_peelbib(f, metadata)
          end
        elsif type == "steele"
          Dir.glob("#{tar_path}/*.tar") do |f|
            Openstack.ingest_steele(f, metadata)
          end

        # elsif type == "generic"
        #   Openstack.ingest_generic("#{tar_path}/1.tar", metadata)
        # end
        elsif type == "generic"
          Dir.glob("#{tar_path}/*.tar") do |f|
            Openstack.ingest_generic(f, metadata)
          end
        end
        File.open(File.join(tar_path,'update.txt')).each do |line|
          puts line
          result = mysql_query(connection, line) unless dryrun
          puts "update result#{result}"
        end

     else
       puts "it is in database"
     end
  end
end
Helpers.close_mysql_connection(connection)
