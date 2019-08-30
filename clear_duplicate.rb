#this is going to merge the two duplicate entries because of the edition

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
cmd="select * from newspapers where newspaper='UNI' and host='jeoffry'"
rs = mysql_query(connection, cmd)
rs.each do |row|
        #puts row
        insert_cmd="INSERT INTO newspapers(newspaper, year, month, day, edition, articles, ads, host) VALUES ('#{row['newspaper']}', #{row['year']}, #{row['month']}, #{row['day']}, 1, #{row['articles']}, #{row['ads']}, '#{row['host']}' ) ON DUPLICATE KEY UPDATE articles=VALUES(articles), ads=VALUES(ads), host=VALUES(host) "
        #puts "#{row['object_name']}"
        delete_cmd="DELETE FROM newspapers where id=#{row['id']}"
        #ary.push(row['code'])
        puts insert_cmd
        #puts delete_cmd
        mysql_query(connection, insert_cmd)
        #mysql_query(connection, delete_cmd)
    end
Helpers.close_mysql_connection(connection)
