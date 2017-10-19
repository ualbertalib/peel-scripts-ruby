Dir.glob("/home/baihong/peel-scripts-ruby/upload_loc/**/tarlist.xml") do |f|
  puts f
  issue_path = File.dirname(f)
  issue = issue_path.split("/").last
  puts issue
  if not Dir.exist?("/media/baihong/UofA Drive 2648-2/UofAlberta/French_Papers/LEQ/LEQ_18980203-19000222/data/LEQ18980203-19000222/LEQ_18980203-19000222/#{issue}")
    puts "This is a LEM"
    %x(cp -R /home/baihong/peel-scripts-ruby/upload_loc/#{issue} /home/baihong/peel-scripts-ruby/upload_lem/)
    puts "LEM moved"
  end
end
