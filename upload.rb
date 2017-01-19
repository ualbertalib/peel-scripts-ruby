require 'net/sftp'
#Upload to jeoffry
Net::SFTP.start('jeoffry.library.ualberta.ca', 'baihong', :password => '100ofrainbows') do |sftp|
  # upload a file or directory to the remote host
  t1 = Time.now
  puts "in process uploading"
  if sftp.upload!("/home/baihong/peel-scripts-ruby/upload", "/var/peel-scripts-ruby/upload")
    puts "upload Finish"
    t2 = Time.now
    delta = t2 - t1
    p "--------------------------------------Success---------------------------------"
    p "------------------uploading takes #{delta} seconds----------------------------"
  end
end
