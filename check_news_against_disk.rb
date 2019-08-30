#This code is going to generate a list queries which check if item in the list is digitized in the openstack
Dir.glob("/media/baihong/RUGGED-4/Shipment_053_2/AlbertaNewspapers/Shipment_67/**/*METS.xml") do |f|
  puts f
  item=File.dirname(f).split("/").last
  puts item
  newspaper=item[0,3]
  year=item[4,4]
  month=item[8,2]
  day=item[10,2]
  #edition=item[12,2]
  cmd="select * from newspapers where newspaper='GAT' and year=#{year} and month=#{month} and day=#{day} and edition=#{edition} and noid IS NOT NULL\n"
  puts cmd
  # File.open('select_news.txt', 'a') { |file| file.write(cmd) }
end
