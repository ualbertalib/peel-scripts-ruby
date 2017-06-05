require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'
require 'net/sftp'
require 'optparse'

#jeoffry end
def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end

connection = Helpers.set_mysql_connection
num=0
exsit=0
not_exsit=0

ary=File.open('object_to_check.marshal', "r"){|from_file| Marshal.load(from_file)}
missing_ary = Array.new
ary.each do |object|
  num=num+1
  cmd="select * from items where code = '#{object}' and noid IS NOT NULL"
  #UPDATE items SET delivery='bkstg0052' WHERE code='N028549';
  puts cmd
  rs = mysql_query(connection, cmd)
  sum=0
  rs.each do |row|
          #puts row
          #puts "#{row['object_name']}"
          sum=sum+1
      end
  if sum==0
    not_exsit=not_exsit+1
    puts "#{num}: #{object} not in database ------------------------#{not_exsit}"
    missing_ary.push(object)
  else
    exsit=exsit+1
    puts "#{num}: #{object} is in database #{exsit}"
  end
end
Helpers.close_mysql_connection(connection)
puts missing_ary
File.open('object_missing.marshal', "w"){|to_file| Marshal.dump(missing_ary, to_file)}

# #local end
# ary = Array.new
#  Dir.glob("/media/baihong/MyBook/UAL/Shipment_052/UAL-PEE-0055/**/*METS.xml") do |f|
#    objectpath=File.dirname(f)
#    puts objectpath
#    object=objectpath.split("/")[-2]
#    #puts object
#    ary.push(object)
#    puts ary
#  end
#  File.open('object_to_check.marshal', "w"){|to_file| Marshal.dump(ary, to_file)}
