require './helpers'
require 'csv'
require 'optparse'

def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end

options = {}
OptionParser.new do |opts|
  opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
end.parse!
p options
dir=options[:directory]
puts dir
disk=dir.split("/")[3]
folder=dir.split("/")[-1]
puts disk
puts folder
connection = Helpers.set_mysql_connection

CSV.open("bkstg_disk_result/#{disk}_#{folder}.csv", "wb") do |csv|
count_exsit=0
count_not_exsit=0
total=0
Dir.glob("#{dir}**/manifest-md5*") do |f|
  total=total+1
  puts f
  item=File.dirname(f).split("/").last
  #item=File.basename(f).split(".").first[0,8]
  puts item
  cmd="select * from items where (code='#{item}' or old_peel_new='#{item}') and noid IS NOT NULL"
  puts cmd
  rs = mysql_query(connection, cmd)
  count=0
  rs.each do |row|
    puts row
    count=count+1
  end
  if count!=0
    count_exsit+=1
    puts "#{total}: #{count_exsit}: exsits in the database"
  else
    count_not_exsit+=1
    puts "#{total}: #{count_not_exsit}: #{item}"
    csv << ["#{item}"]
  end
end
end
