require 'slop'
require './helpers'
require 'ddr-antivirus'
require 'fileutils'
require 'bagit'
require 'net/sftp'



#check if tar file changes
Dir.glob("upload/**/*.xml") do |f|
  #puts f
  tar_path = File.dirname(f)
  folder = tar_path.split("/").last
  #puts folder
  DirToXml.md5remote(tar_path)
  if FileUtils.compare_file(File.join(tar_path,'tarlist.xml'),File.join(tar_path, 'tarlist2.xml'))
    puts "#{folder}: file transfer correct"
  else
    puts "#{folder}: file transfer error"
  end

end
