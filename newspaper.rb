require 'optparse'
require './helpers'


def self.retrieve_noid(noid, container)
  properties = YAML.load_file('properties.yml')
  #temp_dir = properties['temp_dir']
  temp_dir="tmp"
  openstack_swift_url = properties["openstack_swift_url"]
  puts temp_dir
  FileUtils.mkdir_p(temp_dir) && FileUtils.chdir(temp_dir)
  ['alto','mets','jp2'].each do |t|
    get_location = "#{noid}/#{t}/1.tar"
    #swift_cmd = "swift download -D #{temp_dir} #{resource_type} #{get_location}"
    swift_cmd = "swift download #{container} #{get_location}"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdout
  end
end


options = {}
OptionParser.new do |opts|
  opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
end.parse!
dir = options[:directory]
p dir
#for all
connection = Helpers.set_mysql_connection




#for each noid
Dir.glob("#{dir}/*") do |f|
  #puts f
  peelnum = f.split("/").last
  puts peelnum
  getnoid= "select noid from items where code = '#{peelnum}'"
  puts getnoid
  noid = mysql_query(mysql_connection, getnoid)
  retrieve_noid(noid,peel)


























end
