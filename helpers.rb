require 'logger'
require 'stringio'
require 'slop'
require 'fileutils'
require 'open3'
require './bag'
require './dir_to_xml'
require 'mysql'
require 'yaml'
require './utils'
require 'digest'
require 'uri'
require 'net/http'
require 'curb'
require 'openstack'

module Helpers
  def self.write_to_file(content, file_name)
    File.open(file_name, 'w') { |f| f.write(content) }
  end

  def self.read_properties(yaml)
    properties = YAML.load_file(yaml)
  end
end
