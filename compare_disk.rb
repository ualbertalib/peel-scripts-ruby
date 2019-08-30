require 'csv'
CSV.open("nosotros_results/1st_series.csv", "wb") do |csv|
Dir.glob("/media/baihong/UAL-1952/Nosotros\ 1st\ Series/*") do |f|
  puts f
  filename=File.basename(f)
  puts filename
  if File.exist?("/media/baihong/0643AF58077EEFA1/Nosotros_1st_Series/#{filename}")
    puts "file exist #{filename}"
  else
    puts "file not exist #{filename}"
    csv << ["#{f}"]
  end
end
end
