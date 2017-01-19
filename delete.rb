require './helpers'
require './lib/openstack/swift/connection.rb'
require 'byebug'
require 'json'
File.open('delete.txt').each do |line|
  puts line
  stdin, stdout, stderr = Open3.capture3(line)
  puts stdin
  puts stdout
  puts stderr
end
