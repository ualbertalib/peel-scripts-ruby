# this is a script to execute the locally generated file and get a result
require './helpers'
require 'csv'
def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end
connection = Helpers.set_mysql_connection
CSV.open("bkstg_result/toclean", "wb") do |csv|
count_exsit=0
count_not_exsit=0
File.read("select_news.txt").each do |line|
  puts line
  #cmd="select * from items where code='#{item}' and noid IS NOT NULL\n"
  rs = mysql_query(connection, line)
  count=0
  rs.each do |row|
    #puts row
    count=count+1
  end
  if count!=0
    count_exsit+=1
    puts "#{count_exsit}: exsits in the database"
  else
    count_not_exsit+=1
    puts "#{count_not_exsit}: #{line}"
    #csv << ["#{item}"]
  end
 end
end
Helpers.close_mysql_connection(connection)
