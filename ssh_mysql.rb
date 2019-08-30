require 'rubygems'
require 'mysql2'
require 'net/ssh/gateway'

gateway = Net::SSH::Gateway.new(
  'jeoffry.library.ualberta.ca',
  'ddev'
 )
port = gateway.open('127.0.0.1', 3306, 3307)

client = Mysql2::Client.new(
  host: "127.0.0.1",
  username: 'peel',
  password: 'ZjW_6g0Y',
  database: 'peel_blitz',
  port: port
)
results = client.query("select * from items where code='N005109' and noid IS NOT NULL")
results.each do |row|
  p row
end
client.close
