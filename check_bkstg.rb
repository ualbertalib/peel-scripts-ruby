require 'csv'

# Dir.glob("/media/baihong/University_of_Alberta_02/Alberta_Peel_09-050_Shipment_055/UAL/Shipment_055/peel/**/manifest-md5.txt") do |f|
#   puts f
#   item=File.dirname(f).split("/").last
#   puts item
#   cmd="select * from items where code='#{item}' and noid IS NOT NULL\n"
#   puts cmd
#   File.open('select_query.txt', 'a') { |file| file.write(cmd) }
# end

CSV.foreach("Shipment_67.csv") do |row|
  item=row[0]
  cmd="select * from items where code='#{item}' and noid IS NOT NULL\n"
  puts cmd
  File.open('select_bkstg.txt', 'a') { |file| file.write(cmd) }
end
