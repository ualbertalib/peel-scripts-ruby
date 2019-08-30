require 'csv'

CSV.foreach("peel_map_path.csv") do |row|
  puts row
  third=row[0].split("/")[-3]
  puts third
  second=row[0].split("/")[-2]
  first=row[0].split("/")[-1]
  cmd="scp baihong@preston.library.ualberta.ca:/mnt/honeycomb/#{third}/#{second}/#{first} /home/baihong/Documents/user/peel_map/\n"
  File.open('download_peel_map.sh', 'a') { |file| file.write(cmd) }
end
