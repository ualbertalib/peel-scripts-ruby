require 'nokogiri'
require 'mime/types'
require 'digest/md5'
require './helpers'

module DirToXml

  def self.dir2list(directory, file_name)
    xml = dir2xml(directory)
    dir = File.dirname(file_name)
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
    Helpers.write_to_file(xml, file_name)
  end

  def self.dir2xml(directory)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.files {
          Dir.glob(directory+"/**/*") do |o|
            if File.directory?(o)
              xml.dir {
                xml.dirname_ o
                xml.path_ File.dirname(o)
              }
            else
              xml.file {
                xml.filename_ o
                xml.path_ File.dirname(o)
                xml.filetype_ MIME::Types.of(o).first.to_s
                xml.length_ File.size(o)
                xml.last_modified_ File.mtime(o)
                xml.md5_ Digest::MD5.file(o).hexdigest
              }
            end
          end
        }
      }
    end
    return builder.to_xml
  end
  
  def self.validation(directory, file)
    filenum = Dir[directory + "**/*"].count { |file| File.file?(file) }
    doc = Nokogiri::XML(open(file))
    filenodes = doc.search('file').size
    true if File.size(file) > 0 && filenum == filenodes
    false
  end
end
