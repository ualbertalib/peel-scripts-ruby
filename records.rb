require 'spreadsheet'
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
    opts.on("-f", "--file-name FILE", "the files of shipping list which is going to be tracked.") do |v|
      options[:file] = v
    end
  end.parse!
file=options[:file]
puts file
filename=File.basename(file).split(".").first
puts filename
CSV.open("results/#{filename}_mods_records.csv","w",:write_headers=> true,:headers => ["title","Peel no.","version of","mods_record"]) do |csv1|
CSV.open("results/#{filename}_parent.csv","w",:write_headers=> true,:headers => ["title","Peel no."]) do |csv2|
book = Spreadsheet.open(file)
sheet1 = book.worksheet('Shipping list')
sum=0#total
sum2=0#not parent
sum3=0#parent
connection = Helpers.set_mysql_connection
sheet1.each do |row|
  #check if p number exsit
  if not row[1].nil? and not row[5].nil? and row[5].match(/[[:upper:]]+[[:digit:]]{6}/) and row[6].nil?#serioes parent or single item
    sum+=1
    title=row[1]
    node=row[5].match(/[[:upper:]]+[[:digit:]]{6}/)[0]
    first=node[1,2]
    second=node[3,2]
    whole=node[1,6]
    if row[8].nil?
      csv2 << [row[1],row[5]]
    end
    if row[5].match(/N/)
      result=File.file?("/diginit/work/peel/metadata/N/#{first}/#{second}/#{node}.xml")
    elsif row[5].match(/P/)
      result=File.file?("/diginit/work/peel/metadata/P/#{first}/#{second}/#{node}.xml")
    end
    if result==true
      puts "there are mods record for #{node}"
      if not row[7].nil?
        csv1 << [row[1],row[5],row[7],"yes"]
      else
        csv1 << [row[1],row[5],"NA","yes"]
      end
    else
      puts "no mods record for #{node}"
      if not row[7].nil?
        csv1 << [row[1],row[5],row[7],"no"]
      else
        csv1 << [row[1],row[5],"NA","no"]
      end
    end
  end
end
Helpers.close_mysql_connection(connection)
end
end
