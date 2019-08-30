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
CSV.open("bkstg_result/N_code_missing.csv", "wb") do |csv1|
count_exsit=0
count_not_exsit=0
CSV.foreach("bkstg/N_code.csv",skip_blanks: true) do |line|
  item=line[0]
  puts item
  cmd="select * from items where (code='#{item}' or old_peel_new='#{item}') and noid IS NOT NULL"
  rs = mysql_query(connection, cmd)
  count=0
  rs.each do |row|
    #puts row["code"]
    count=count+1
  end
  if count!=0
    count_exsit+=1
    puts "#{count_exsit}: #{item} exsits in the database"
  else
    count_not_exsit+=1
    puts "#{count_not_exsit}: #{item} does not exsit in the database"
    csv1 << ["#{item}"]
  end
 end
end
Helpers.close_mysql_connection(connection)
