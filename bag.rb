require './helpers'

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

  def self.bagit_create(files, basedir)
    properties = YAML.load_file('properties.yml')
    temp_dir = properties['temp_dir']
    File.delete(*Dir.glob('#{directory}\**\.DS_Store'))
    File.delete(*Dir.glob('#{directory}\**\Thumbs.db'))
    basename = File.basename(File.dirname(files.first))
    bag_dir = File.join(temp_dir, basename, basedir)
    bagit_create_cmd = "bag create #{bag_dir} #{files.join(' ')}"
    puts bagit_create_cmd
    stdin, stdout, stderr = Open3.capture3(bagit_create_cmd)
    return bag_dir
  end
end
