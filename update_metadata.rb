Dir.glob("/home/baihong/peel-scripts-ruby/newspaper_to_upload/upload_gtw2/**/tarlist.xml") do |f|
  issue=File.dirname(f).split("/").last
  puts issue
  issue_path=File.dirname(f)
  puts issue_path
  date = issue[6,2]
  puts date
  month = issue[4,2]
  puts month
  year = issue[0,4]
  puts year
  metadata=File.open(File.join(issue_path,"metadata.marshal"), "r"){|from_file| Marshal.load(from_file)}
  noid = metadata['noid']
  puts noid
  metadata1 = {"publication" => "GAT", "year"=> year, "month" => month, "date" => date, "noid" => noid }
  puts metadata1
  File.open(File.join(issue_path,'metadata1.marshal'), "w"){|to_file| Marshal.dump(metadata1, to_file)}
end
