require 'optparse'
require './helpers'

options = {}
OptionParser.new do |opts|
  opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
end.parse!
dir = options[:directory]
p dir

count=0
Dir.glob("#{dir}/**/*-METS.xml") do |f|
  issue_path = File.dirname(f)
  #puts issue_path
  folderlist=issue_path.split("/")
  peelnum =folderlist[6]
  puts"---------------------------------"
  puts "Folder #{peelnum}"
  whmname = folderlist.last
  issue = whmname.split("_").last
  #puts issue
  jp2_num=Dir.glob("#{issue_path}/**/*.jp2").count
  puts "jp2 numer: #{jp2_num}"
  xml_count=Dir.glob("#{issue_path}/**/*.xml").grep(/[^METS].xml/).count
  puts "xml numer: #{xml_count}"
  if jp2_num!=xml_count
    puts "number not match in folder #{peelnum}"
    count=count+1
  end
end
puts "-------------------RESULT--------------------------"
puts "#{count} folders are not match"
