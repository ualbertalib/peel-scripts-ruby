require './helpers'
require 'fileutils'

module Utils
  def self.tar(outputfile, directory)
    unless File.directory?(File.dirname(outputfile))
      FileUtils.mkdir_p(File.dirname(outputfile))
    end    
    output = `tar -cvf #{outputfile} -C #{directory} .`
    if $?.success?
      puts "created a tar for #{directory} at #{outputfile}"
    else
      raise "Error when creating tar for #{directory}"
    end

  end 

  def self.untar(filename, outputdir)
    unless File.directory?(outputdir)
      FileUtiles.mkdir_p(outputdir)
    end
    output = `tar -C #{outputdir} -xvf #{filename}`
    if $?.success?
      puts "extracted #{filename} at #{outputdir}"
    else
      raise "Error when extracting tar #{filename} at #{outputdir}"
    end
  end
    

  def self.noid
    properties = YAML.load_file('properties.yml')
    noid_minter = properties['noid_minter']
    noid = Net::HTTP.get(URI noid_minter)[/(dig\S+)/,1]
  end  

end
