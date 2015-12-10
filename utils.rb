require './helpers'

module Utils
  def self.tar(outputfile, directory)
    output = `tar -cvf #{outputfile} #{directory}`
    if $?.success?
      puts "created a tar for #{directory} at #{outputfile}"
    else
      raise "Error when creating tar for #{directory}"
    end

  end 

  def self.noid
    properties = YAML.load_file('properties.yml')
    noid_minter = properties['noid_minter']
    noid = Net::HTTP.get(URI noid_minter)[/(dig\S+)/,1]
  end  

end
