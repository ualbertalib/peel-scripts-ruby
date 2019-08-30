require 'nokogiri'

#doc = Nokogiri::Slop(File.open("/home/baihong/peel-scripts-ruby/upload_ab25k/AB_25K_Topo_73D-10F-5/tarlist.xml"))
doc = Nokogiri::XML(File.open("/home/baihong/peel-scripts-ruby/upload_arial/A11693/tarlist.xml"))
puts doc.xpath("//length/text()")
puts doc.xpath("//length/text()").count



# doc = Nokogiri::Slop(File.open("/home/baihong/peel-scripts-ruby/upload_ab25k/AB_25K_Topo_73D-10F-5/tarlist.xml"))
# # <employees>
# #   <employee status="active">
# #     <fullname>Dean Martin</fullname>
# #   </employee>
# #   <employee status="inactive">
# #     <fullname>Jerry Lewis</fullname>
# #   </employee>
# # </employees>
# # EOXML
#
# # navigate!
# puts doc.root
# puts doc.employees.employee.last.fullname.content # => "Jerry Lewis"
