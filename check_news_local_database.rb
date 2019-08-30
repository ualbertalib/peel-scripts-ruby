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
Dir.glob("#{dir}**/*METS.xml") do |f|
  total=total+1
  puts f
  # # version 1: code_issue
  # item=File.dirname(f).split("/").last
  # puts item
  # year=item[4,4]
  # month=item[8,2]
  # day=item[10,2]
  # code=item[0,3]

  # # version 2: issue only
  # item=File.dirname(f).split("/").last
  # section=File.dirname(f).split("/")[-2]
  # puts section
  # year=item[0,4]
  # month=item[4,2]
  # day=item[6,2]
  # code="LBT"
  # if section=='SECTION-A'
  #   edition='01'
  # elsif section=='SECTION-B'
  #   edition='02'
  # elsif section=='SECTION-C'
  #   edition='03'
  # else
  #   edition='01'
  # end



  # version 3: issue in basename
  item=File.basename(f)[0,12]
  puts item
  year=item[4,4]
  month=item[8,2]
  day=item[10,2]
  code=item[0,3]
  edition=01


  # # version 4: mixed years newspapers
  # item=File.dirname(f).split("/").last
  # puts item
  # year=item[0,4]
  # month=item[4,2]
  # day=item[6,2]
  # #edition=item[8,2]
  # edition=01
  # code="WHM"




  cmd="select * from newspapers where newspaper='#{code}' and year=#{year} and month=#{month} and day=#{day} and edition=#{edition} and noid is not NULL"
  #cmd="select * from newspapers where newspaper='#{code}' and year=#{year} and month=#{month} and day=#{day} and noid is not NULL"

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
    puts "#{total}: #{count_not_exsit}: #{item} does not exsits in the database"
    csv << ["#{item}"]
  end
end
end
