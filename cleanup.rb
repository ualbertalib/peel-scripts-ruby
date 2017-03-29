require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'
require 'net/sftp'
require 'optparse'


def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end
ary = Array.new
connection = Helpers.set_mysql_connection
cmd='select code from items where digstatus ="digitized" and copyright ="clear" and noid is not null and delivery like "bkstg%"'
rs = mysql_query(connection, cmd)
rs.each do |row|
        #puts "#{row['code']}"
        ary.push(row['code'])
    end
Helpers.close_mysql_connection(connection)
puts ary
#File.open(File.join(temp_location,'metadata.marshal'), "w"){|to_file| Marshal.dump(metadata, to_file)}
File.open('object.marshal', "w"){|to_file| Marshal.dump(ary, to_file)}
puts"------------------------------"
# Dir.glob("upload/**/tarlist.xml") do |f|
#   # puts f
#   tar_path = File.dirname(f)
#   #puts tar_path
#   folder = tar_path.split("/").last
#   if ary.include?("#{folder}")
#     puts folder
#     FileUtils.rm_rf(tar_path)
#   end
#   puts "all #{folder}"
# end
