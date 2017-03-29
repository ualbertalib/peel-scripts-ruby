require 'bagit'

number = 0
Dir.glob("/media/baihong/UA Digital_init 9375/generic/Rutherford/**/manifest-md5.txt") do |d|
  object_path = File.dirname(d)
  #puts object_path
  number = number +1
  begin
  bag = BagIt::Bag.new object_path
  if bag.valid?
  puts "#{object_path} is valid #{number}"
else
  puts "#{object_path} is not valid #{number}"
end
  rescue
    puts "#{object_path} not supported #{number}"
  end

end

# object_path="/media/baihong/UA\ Digital_init\ 9375/generic/Rutherford/69.164.2.2.3.4.2.3"
# bag = BagIt::Bag.new object_path
# if bag.valid?
# puts "#{object_path} is valid"
# else
# puts "#{object_path} is not valid"
# end
