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
CSV.open("#{dir}found.csv", "w") do |csv|
CSV.foreach('Combined_missing.csv',skip_blanks: true) do |row|
  total+=1
  item=row[0]
  puts item
  if (Dir.glob("#{dir}**/*#{item}*").count)>0
    yes+=1
    puts "Total number: #{total} NO: #{yes}: #{item} exist"
    csv << ["#{item}"]
  else
    no+=1
    puts "Total number: #{total} not exsit #{no}"
  end
end
end

# CSV.foreach('/media/baihong/Rugged-6/found.csv') do |row|
#   total+=1
#   item=row[0]
#   puts item
#   %x(cp -r /media/baihong/Rugged-6/UAL/Shipment_049/UAL-PEE-0054/#{item}/ /media/baihong/Rugged-6/UAL/missing/#{item}/)
# end
