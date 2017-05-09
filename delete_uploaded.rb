ary = Array.new
Dir.glob("/diginit/work/upload/**/tarlist.xml") do |d|
  #puts d
  object_name=File.dirname(d).split("/").last
  ary.push(object_name)
  #puts object_name
end
puts ary
