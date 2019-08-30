File.open("newspaper_uniq.csv", "w+") do |file|
  file.puts File.readlines("newspaper.csv").uniq! { |s| s[/^\d+/ ] }
end
