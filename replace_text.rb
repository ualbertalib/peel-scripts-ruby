# file_names = ['insert_lem.txt']
#
# file_names.each do |file_name|
#   text = File.read(file_name)
#   new_contents = text.gsub(/02/, "01")
#
#   # To merely print the contents of the file, use:
#   puts new_contents
#
#   # To write changes to the file, use:
#   File.open("insert_lem1.txt", "w") {|file| file.puts new_contents }
# end

#search for all the lem insert, replace and combine together
Dir.glob("/home/baihong/peel-scripts-ruby/upload_lem/**/update.txt") do |f|
  puts f
  text = File.read(f)
  new_contents = text.gsub(/LOC/, "LEM")
  puts new_contents
  File.open("update_lem.txt", "a") {|file| file.puts new_contents }
end

# Dir.glob("/home/baihong/peel-scripts-ruby/upload_loc1/**/update.txt") do |f|
#   puts f
#   text = File.read(f)
#   File.open("update_loc.txt", "a") {|file| file.puts text }
# end
