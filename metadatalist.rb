require 'fileutils'
require 'csv'
require 'nokogiri'

ary=File.open("object.marshal", "r"){|from_file| Marshal.load(from_file)}
CSV.open("object_name.csv","w") do |csv|
ary.each do |object|
  #puts object
  first=object[1,2]
  second=object[3,2]
  whole=object[1,6]
  #puts first
  #puts second
  #puts whole
  on="aaa"
  result=File.file?("/diginit/work/peel/metadata/N/#{first}/#{second}/#{object}.xml")
  if result==true
    doc = Nokogiri::XML(File.open("/diginit/work/peel/metadata/N/#{first}/#{second}/#{object}.xml"))
    #puts doc
    puts object
    doc.xpath('//xmlns:mods/xmlns:titleInfo/xmlns:title').each do |object_name|
    #puts "yes"
    puts object_name.text
    on=object_name.text
    #csv << [object,object_name.text]
  end
  csv << [object,on]
    #ary2.push(object)
  end
end
end
# puts ary2
# File.open('object_with_metadata.marshal', "w"){|to_file| Marshal.dump(ary2, to_file)}
