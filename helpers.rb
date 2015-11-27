require 'logger'
require 'stringio'
require 'slop'
require 'fileutils'
require 'open3'
require './bag'
require './dir_to_xml'
require 'mysql'
require 'yaml'

module Helpers
  def self.write_to_file(content, file_name)
    File.open(file_name, 'w') { |f| f.write(content) }
  end
end
