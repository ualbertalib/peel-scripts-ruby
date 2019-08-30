require 'csv'
require 'optparse'
total=0
yes=0
no=0
options = {}
OptionParser.new do |opts|
  opts.on("-d", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
end.parse!
dir = options[:directory]
p dir
CSV.foreach("#{dir}found.csv") do |row|
  total+=1
  item=row[0]
  puts item

 Dir.glob("#{dir}/**/*#{item}*") do |f|
   puts f
 end

end



#  if (Dir.glob("/media/baihong/BSLW-PR-14/**/*Alberta_Peel_09-050_Shipmen56756765*").count)>0
#    puts "yes"
# end
