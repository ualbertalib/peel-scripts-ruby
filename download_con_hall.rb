require './helpers'
def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end
connection = Helpers.set_mysql_connection

%x(mkdir con_hall)
cmd="select * from digitization_noids where collection like '%convocation%' and id<270"
rs = mysql_query(connection, cmd)
rs.each do |row|
  puts "Download noid -----------: #{row['noid']}"
  %x(swift download digitization -p #{row['noid']} -D con_hall/)
  %x(tar -xvf con_hall/#{row['noid']}/1.tar -C con_hall/)

end

Helpers.close_mysql_connection(connection)
