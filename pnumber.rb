require 'csv'
t = CSV.read('hender.csv',:headers=>true)
codes=t['code']
CSV.open("object_name.csv","w") do |csv|
pnumber= 10673
CSV.foreach("staged_object.csv") do |row|
  #pnumber=pnumber+1
  #puts row,pnumber
   if not codes.include?(row[0])
     pnumber=pnumber+1
    csv << [row[0],"P0#{pnumber}"]
  end
end
end
