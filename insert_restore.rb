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

connection = Helpers.set_mysql_connection
line_num=0
text=File.open('update_lem.txt').read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
  line_num=line_num+1
  print "#{line_num} #{line}"
  #puts line
  mysql_query(connection, line)
end
Helpers.close_mysql_connection(connection)





# line_num=0
# text=File.open('insert_query.txt').read
# text.gsub!(/\r\n?/, "\n")
# text.each_line do |line|
#   line_num=line_num+1
#   print "#{line_num} #{line}"
#   # if line_num%2!=0
#   #   print "#{line_num} #{line}"
#   #   File.open("insert_query.txt", 'a') { |file| file.write("#{line}") }
#   # end
# end
