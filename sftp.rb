require 'net/sftp'

module Jeoffry

#
# Net::SFTP.start('jeoffry.library.ualberta.ca', 'baihong', :password => '100ofrainbows') do |sftp|
#   # upload a file or directory to the remote host
#   if sftp.upload!("/home/baihong/peel-scripts-ruby/upload", "/home/baihong/peel-scripts-ruby/upload")
#     puts "upload Finish"
#   end
# end

def self.upload()
  Net::SFTP.start('jeoffry.library.ualberta.ca', 'baihong', :password => '100ofrainbows') do |sftp|
    # upload a file or directory to the remote host
    if sftp.upload!("/home/baihong/peel-scripts-ruby/upload", "/home/baihong/peel-scripts-ruby/upload")
      puts "upload Finish"
    end
  end
end
