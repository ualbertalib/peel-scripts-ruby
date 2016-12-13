require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'
require 'net/sftp'


def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end


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
logfile = "log/remote-#{last_dir}-#{timestamp}"
logger = Logger.new(logfile)
logger.info "Start check if upload Successfully"
#check if tar file changes
connection = Helpers.set_mysql_connection
Dir.glob("upload/**/*.xml") do |f|
  #puts f
  tar_path = File.dirname(f)
  folder = tar_path.split("/").last
  #puts folder
  DirToXml.md5remote(tar_path)
  if FileUtils.compare_file(File.join(tar_path,'tarlist.xml'),File.join(tar_path, 'tarlist2.xml'))
    puts "#{folder}: file transfer correct"
    #logger.info "#{folder}: file transfer correct"
  else
    puts "#{folder}: file transfer error"
    #logger.error "#{folder}: file transfer error"
  end
  File.open(File.join(tar_path,'insert.txt')).each do |line|
    puts line
    result = mysql_query(connection, line) unless dryrun
  end
  puts "finish insert into the database"
  #push to openstack
  metadata=File.open(File.join(tar_path,"metadata.marshal"), "r"){|from_file| Marshal.load(from_file)}
  puts metadata
  if type == "newspaper"
    Dir.glob("#{tar_path}/*.*") do |f|
      Openstack.ingest_newspaper(f,metadata)
    end
  elsif type == "peelbib"
    Dir.glob("#{tar_path}/*.*") do |f|
      Openstack.ingest_peelbib(f, metadata)
    end
  elsif type == "steele"
    Dir.glob("#{tar_path}/*.*") do |f|
      Openstack.ingest_steele(f, metadata)
    end
  elsif type == "generic"
    Openstack.ingest_generic("#{tar_path}/1.tar", metadata)
  end
  #update the database
  File.open(File.join(tar_path,'update.txt')).each do |line|
    puts line
    #result = mysql_query(connection, line) unless dryrun
   end
 end
 Helpers.close_mysql_connection(connection)
# #check in the database
