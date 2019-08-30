require 'csv'
require "./helpers"


def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end
connection = Helpers.set_mysql_connection
count_exsit=0
count_not_exsit=0
CSV.foreach("peel_request.csv",skip_blanks: true) do |line|
  item=line[2][5,7]
  puts item
  cmd="select * from items where code like 'P00#{item}' and noid IS NOT NULL"
  rs = mysql_query(connection, cmd)
  count=0
  puts rs
  rs.each do |row|
    noid = row['noid']
    puts noid
    puts "swift download peel #{noid}/pdf/1.pdf -o peel_request/#{item}/"
    #{}%x(swift download peel #{noid}/pdf/1.pdf -o 9534/#{item}.pdf)
    swift_cmd = "swift download peel #{noid}/pdf/1.pdf -o peel_request/#{item}.pdf"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdin
    puts stdout
    puts stderr

    count=count+1
  end
  if count!=0
    count_exsit+=1
    puts "#{count_exsit}: #{item} exsits in the database"
  else
    count_not_exsit+=1
    puts "#{count_not_exsit}: #{item} does not exsit in the database"
  end
 end
Helpers.close_mysql_connection(connection)
