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

CSV.open("results/items_untracked.csv","w") do |csv|
connection = Helpers.set_mysql_connection
start = 711
while start <=716
  code ="N030#{start}"
  #puts code
  query="select code,noid from items where code='#{code}'"
  puts query
  result = mysql_query(connection, query)
  if result.count!=0
    puts "#{code} exsit in database"
    result.each do |row|
      #csv2 << [row[1],row3['code'],row3['old_peel_new']]
      File.open("download.sh", 'a') { |file| file.write("swift download peel #{row['noid']}/pdf/1.tar\n") }
      #puts "#{code}: #{row['noid']}"
    end
    #File.open("download.sh", 'a') { |file| file.write("swift ") }
    #download from openstack
  else
    puts "#{code} does not in database-----------------"
    csv << [code]
  end

  start +=1
end
Helpers.close_mysql_connection(connection)
end
