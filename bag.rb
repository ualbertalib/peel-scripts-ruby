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
end
