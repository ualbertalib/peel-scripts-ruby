require 'logger'
require 'stringio'
require 'slop'
require 'fileutils'
require 'open3'
require './bag'
require './dir_to_xml'
require 'mysql2'
require 'yaml'
require './utils'
require 'digest'
require 'uri'
require 'net/http'
require 'curb'
require './openstack'
module Helpers
  def self.write_to_file(content, file_name)
    File.open(file_name, 'w') { |f| f.write(content) }
  end

  def self.read_properties(yaml)
    properties = YAML.load_file(yaml)
  end

  def self.set_mysql_connection
    database_config = YAML.load_file('database.yml')
    username = database_config['username']
    password = database_config['password']
    database = database_config['database']
    hostname = database_config['hostname']
    connection = Mysql2::Client.new(:host => hostname, :username => username, :password => password, :database => database)
  end

  def self.close_mysql_connection(connection)
    connection.close
  end


end
