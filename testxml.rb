require 'nokogiri'
doc = Nokogiri::XML(File.open("test.xml"))
#puts doc
doc.xpath('//xmlns:batch/xmlns:reel').each do |object_name|
puts "yes"
puts object_name
#csv << [object,object_name]
end
