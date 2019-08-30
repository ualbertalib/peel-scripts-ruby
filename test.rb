require 'bagit'
existing_base_path="/media/baihong/Didsbury/Output/Didsbury/DidsburyR/1991"
bag = BagIt::Bag.new existing_base_path

if bag.valid?
  puts "#{existing_base_path} is valid"
else
  puts "#{existing_base_path} is not valid"
end
