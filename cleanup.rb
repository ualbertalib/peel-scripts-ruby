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
cmd="select * from newspapers where newspaper='VR' and delivery_date>='2017-10-13' and noid is not NULL"
rs = mysql_query(connection, cmd)
rs.each do |row|
        #puts row
        #puts "#{row['object_name']}"
        if row['month']<10
          month="0#{row['month']}"
        else
          month=row['month']
        end
        if row['day']<10
          day="0#{row['day']}"
        else
          day=row['day']
        end
        ary.push("VR_#{row['year']}#{month}#{day}_article")
        #need to change it into standard
    end
Helpers.close_mysql_connection(connection)
puts ary
# ary.each do |noid|
#   puts noid
#   value=%x(swift delete newspapers #{noid}/pdf/1.tar)
#   puts value
# end
#File.open(File.join(temp_location,'metadata.marshal'), "w"){|to_file| Marshal.dump(metadata, to_file)}
#File.open('object_to_delete.marshal', "w"){|to_file| Marshal.dump(ary, to_file)}
# ary=File.open('object_missing.marshal', "r"){|from_file| Marshal.load(from_file)}
puts"------------------------------"
sum=0
sum1=0
sum2=0
Dir.glob("/diginit/work/upload/va3/**/tarlist.xml") do |f|
  puts f
  sum=sum+1
  tar_path = File.dirname(f)
  #puts tar_path
  folder = tar_path.split("/").last
  puts folder
  if ary.include?("#{folder}")
    sum1=sum1+1
    puts "#{sum}: #{folder} is in database #{sum1}"
    FileUtils.rm_rf(tar_path)
  else
    sum2=sum2+1
    puts "#{sum}: #{folder} is not in database---------- #{sum2}"
  end
  puts "all #{folder}"
end

#select code,noid,ts from items where delivery="bkstg0055" and noid!="NULL";
