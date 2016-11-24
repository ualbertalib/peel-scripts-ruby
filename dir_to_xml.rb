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

  def self.generatemd5 (directory)
    xml = dir2md5(directory)
    Helpers.write_to_file(xml, File.join(directory,"tarlist.xml"))
  end

  def self.md5remote(directory)
    xml = dir2md5(directory)
    Helpers.write_to_file(xml, File.join(directory,"tarlist2.xml"))
  end

  def self.dir2md5(directory)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.files {
          Dir.glob(directory+"/**/*.tar") do |o|
              xml.file {
                xml.filename_ o
                xml.filetype_ MIME::Types.of(o).first.to_s
                xml.length_ File.size(o)
                xml.md5_ Digest::MD5.file(o).hexdigest
              }
          end
        }
      }
    end
    return builder.to_xml
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
    filenum = Dir[directory + "/**/*"].count { |file| File.file?(file) }
    #puts "filenum in the folder"+filenum.to_s
    doc = Nokogiri::XML(open(file))
    filenodes = doc.search('file').size
    #puts "filennode"+filenodes.to_s
    if File.size(file) > 0 && filenum==filenodes
      true
    else
      false
    end
  end
end
