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
CSV.open("bkstg_result/Newspapers_missing.csv", "wb") do |csv1|
CSV.open("bkstg_result/Newspapers_code.csv", "wb") do |csv2|
count_exsit=0
count_not_exsit=0
CSV.foreach("bkstg/GAT_missing.csv",skip_blanks: true) do |line|
  item=line[0]
  puts item
  year=item[0,4]
  month=item[4,2]
  day=item[6,2]
  cmd="select * from newspapers where year=#{year} and month=#{month} and day=#{day} and noid is not NULL"
  #cmd="select * from newspapers where newspaper='GAT' and year=#{year} and month=#{month} and day=#{day} and noid is not NULL"
  rs = mysql_query(connection, cmd)
  count=0
  rs.each do |row|
    puts row["newspaper"]
    count=count+1
  end
  if count!=0
    count_exsit+=1
    puts "#{count_exsit}: #{item} exsits in the database"
    rs.each do |row|
    csv2 << ["#{item}","#{row["newspaper"]}"]

    end
  else
    count_not_exsit+=1
    puts "#{count_not_exsit}: #{item} does not exsit in the database"
    csv1 << ["#{item}"]
  end
 end
end
end
Helpers.close_mysql_connection(connection)
