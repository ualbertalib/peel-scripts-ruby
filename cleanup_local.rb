require 'fileutils'

ary=File.open("delete_folder.marshal", "r"){|from_file| Marshal.load(from_file)}
Dir.glob("upload/**/tarlist.xml") do |f|
  # puts f
  tar_path = File.dirname(f)
  #puts tar_path
  folder = tar_path.split("/").last
  if ary.include?("#{folder}")
    puts folder
    FileUtils.rm_rf(tar_path)
  end
  puts "all #{folder}"
end
