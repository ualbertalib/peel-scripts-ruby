require 'csv'
CSV.open("staged_object.csv","w") do |csv|
Dir.glob("/diginit/work/metsalto/peelbib/N/**/staged") do |f|
  p f
  object = File.dirname(f).split("/").last
  p object
  csv << [object]
end
end
