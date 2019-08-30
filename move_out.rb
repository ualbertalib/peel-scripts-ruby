require 'fileutils'
ary = Array.new
Dir.glob("/home/baihong/peel-scripts-ruby/upload_islam/**/tarlist.xml") do |d|
  #puts d
  object_name=File.dirname(d).split("/").last
  ary.push(object_name)
  #puts object_name
end
#puts ary
Dir.glob("/media/baihong/UAL_8466/Sounds\ of\ Islam\ -\ Frishkopf/**/*.wav") do |f|
  p f
  music_name=File.basename(f).split(".").first
  p music_name
  if ary.include?("#{music_name}")
       puts "found"
       FileUtils.cp f,"/media/baihong/UAL_8466/processed/"
    end
end
