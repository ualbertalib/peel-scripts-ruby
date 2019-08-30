require 'csv'
col_data = []
CSV.foreach('bkstg_result/news_found.csv') {|row| col_data << "#{row[0]}"}
puts col_data


puts "================================================="
CSV.open("bkstg_result/Peel_missing.csv", "wb") do |csv1|
CSV.foreach("bkstg_result/Shipment67_missing.csv",skip_blanks: true) do |line|
  code = line[0]
  puts code
  if not col_data.include? (code)
    puts "not include #{code}"
    csv1 << ["#{code}"]
  end
end
end
