File.open("token","w") do |result|
File.open("header","r") do |handle|
  handle.each_line do |line|
    if line.split(": ")[0]=="X-Subject-Token"
      #puts line.split(": ")[1]
      result << line.split(": ")[1]
    end
  end
end
end
