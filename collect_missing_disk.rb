require 'csv'
CSV.foreach('/home/baihong/peel-scripts-ruby/bkstg_result/toclean.csv') do |row|
  item=row[0]
  puts item
  Dir.glob("/media/baihong/Cache/peel/**/#{item}/manifest-md5.txt") do |f|
    puts f
    issue_path = File.dirname(f)
    puts issue_path
    %x(cp -r #{issue_path} /media/baihong/Cache/missing/)
   end
end
