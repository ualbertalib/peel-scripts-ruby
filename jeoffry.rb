require 'rubygems'
require 'net/ssh'

@hostname = "jeoffry.library.ualberta.ca"
@username = "baihong"
@password = "100ofrainbows"
@cmd = "ls -al"

 begin
    ssh = Net::SSH.start(@hostname, @username, :password => @password)
    res = ssh.exec!(@cmd)
    ssh.close
    puts res
  rescue
    puts "Unable to connect to #{@hostname} using #{@username}/#{@password}"
  end
