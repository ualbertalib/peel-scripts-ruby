require 'optparse'
require 'fileutils'
require 'csv'
# value= %x(convert PC015437v.tif -units PixelsPerInch -density 72 -quality 90 -resize 800 www/PC015437.verso.jpg)
# puts value

options = {}
OptionParser.new do |opts|
  opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
end.parse!
dir = options[:directory]

CSV.open("results/thumbs_r.csv","w",:write_headers=> true,:headers => ["Type","Name","Length","Width"]) do |csv|
Dir.glob("#{dir}/*r.tif") do |f|
   puts f
   file = File.basename(f)
   puts file
   filename = file.split(".").first[0,8]
   code= file.split(".").first[2,3]
   puts filename
   puts code
   target_dir = "PC/#{code}/thumbs"
   if Dir.exist?(target_dir)
     value= %x(convert #{f} -units PixelsPerInch -density 72 -quality 90 -resize 200 #{target_dir}/#{filename}.jpg)
     puts value
   else
     FileUtils::mkdir_p target_dir
     value= %x(convert #{f} -units PixelsPerInch -density 72 -quality 90 -resize 200 #{target_dir}/#{filename}.jpg)
     puts value
   end
   identify = %x(identify #{target_dir}/#{filename}.jpg)
   puts identify
   result_list = identify.split(" ")
   #puts result_list
   item=result_list[0].split("/").last
   puts item
   length = result_list[2][0,3]
   puts length
   width = result_list[2][4,3]
   puts width
   csv << ["thumbs",item,length,width]




end
end


# target_dir = "www/pcimages/015/web"
# if Dir.exist?(target_dir)
#   value= %x(convert PC015437v.tif -units PixelsPerInch -density 72 -quality 90 -resize 800 #{target_dir}/PC015437.jpg)
#   puts value
# else
#   FileUtils::mkdir_p target_dir
#   value= %x(convert PC015437v.tif -units PixelsPerInch -density 72 -quality 90 -resize 800 #{target_dir}/PC015437.jpg)
#   puts value
# end
