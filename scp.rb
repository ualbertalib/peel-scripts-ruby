require 'net/scp'

options = {recursive: true}
# upload a file to a remote server
Net::SCP.upload!("jeoffry.library.ualberta.ca", "baihong",
  "/home/baihong/peel-scripts-ruby/upload/.", "/home/baihong/testfolder"
  :ssh => { :password => "100ofrainbows" })
