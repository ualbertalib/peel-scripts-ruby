#This code is going to generate a list queries which check if item in the list is digitized in the openstack
Dir.glob("/media/baihong/University_of_Alberta_02/Alberta_Peel_09-050_Shipment_055/UAL/Shipment_055/peel/**/manifest-md5.txt") do |f|
  puts f
  item=File.dirname(f).split("/").last
  puts item
  cmd="select * from items where code='#{item}' and noid IS NOT NULL\n"
  puts cmd
  File.open('select_shipment56.txt', 'a') { |file| file.write(cmd) }
end
