require './helpers'
require 'bagit'

module Bag
  def self.bagit_verify(directory)
    timestamp = Time.now.to_s.tr(" ", "_")
    bagit_valid_cmd = "bag verifyvalid #{directory}"
    puts "#{bagit_valid_cmd}"
    stdin, stdout, stderr = Open3.capture3(bagit_valid_cmd)
    if stdin.include?("true")
      puts "#{directory} is a valid bag."
      true
    else
      puts "#{stdin}"
      false
    end
  end

  def self.bagit_create(files, basedir, item)
    properties = YAML.load_file('properties.yml')
    temp_dir = properties['temp_dir']
    File.delete(*Dir.glob('#{directory}\**\.DS_Store'))
    File.delete(*Dir.glob('#{directory}\**\Thumbs.db'))
    if files.kind_of?(Array)
      basename = File.basename(File.dirname(files.first))
      bag_dir = File.join(temp_dir, item, basedir)
      bagit_create_cmd = "bag create #{bag_dir} #{files.join(' ')}"
    elsif File.directory?(files)
      basename = File.basename(files)
      bag_dir = File.join(temp_dir, item, basedir)
      bagit_create_cmd = "bagit -f #{Dir.glob(files+'/*').join(' ')} #{bag_dir}"
    end
    puts bagit_create_cmd
    stdin, stdout, stderr = Open3.capture3(bagit_create_cmd)
    return bag_dir
  end
end
