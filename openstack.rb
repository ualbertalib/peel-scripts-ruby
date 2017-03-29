require './helpers'
require './lib/openstack/swift/connection.rb'
require 'byebug'
require 'json'

module Openstack

  def self.retrieve_noid(noid, container)
    properties = YAML.load_file('properties.yml')
    #temp_dir = properties['temp_dir']
    temp_dir="tmp"
    openstack_swift_url = properties["openstack_swift_url"]
    puts temp_dir
    FileUtils.mkdir_p(temp_dir) && FileUtils.chdir(temp_dir)
    ['alto','mets','tiff','jp2'].each do |t|
      get_location = "#{noid}/#{t}/1.tar"
      #swift_cmd = "swift download -D #{temp_dir} #{resource_type} #{get_location}"
      swift_cmd = "swift download #{container} #{get_location}"
      puts swift_cmd
      stdin, stdout, stderr = Open3.capture3(swift_cmd)
      puts stdout
    end
  end


  def self.ingest_generic(file, metadata)
    properties = YAML.load_file('properties.yml')
    checksum = Digest::MD5.hexdigest(file)
    size = File.size(file)
    noid = metadata['noid']
    collection = metadata['collection']
    file_name = metadata['file_name']
    extension = File.extname(file)
    file_type = File.basename(file).split('.').first
    openstack_swift_url = properties["openstack_swift_url"]
    put_url = "#{openstack_swift_url}/digitization/#{noid}/1#{extension}"
    put_location = "#{noid}/1#{extension}"
    swift_cmd =  "swift upload -H \"X-Object-Meta-Collection: #{collection}\" -H \"X-Object-Meta-filename: #{file_name}\" digitization #{file} --object-name=#{put_location}"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdin
    puts stdout
    puts stderr
  end


  def self.ingest_newspaper(file, metadata)
    properties = YAML.load_file('properties.yml')
    checksum = Digest::MD5.hexdigest(file)
    size = File.size(file)
    publication = metadata['publication']
    year = metadata['year']
    month = metadata['month']
    date = metadata['date']
    edition = metadata['edition']
    noid = metadata['noid']
    # extension = File.extname(file)
    # file_type = File.basename(file).split('.').first
    extension = File.extname(file)
    if extension == ".tar"
      file_type = File.basename(file).split('.').first
    elsif extension == ".pdf"
      file_type = "pdf"
    end
    openstack_swift_url = properties["openstack_swift_url"]
    put_url = "#{openstack_swift_url}/newspaper/#{noid}/#{file_type}/1#{extension}"
    put_location = "#{noid}/#{file_type}/1#{extension}"
    swift_cmd =  "swift upload -H \"X-Object-Meta-Newspaper: #{publication}\" -H \"X-Object-Meta-Year: #{year}\" -H \"X-Object-Meta-Month: #{month}\" -H \"X-Object-Meta-Day: #{date}\" newspapers  #{file} --object-name=#{put_location}"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdin
    puts stdout
    puts stderr
  end

  def self.ingest_peelbib(file, metadata)
    checksum = Digest::MD5.hexdigest(file)
    size = File.size(file)
    noid = metadata['noid']
    peelnum = metadata['peelnum']
    extension = File.extname(file)
    if extension == ".tar"
      file_type = File.basename(file).split('.').first
    elsif extension == ".pdf"
      file_type = "pdf"
    end
    properties = YAML.load_file('properties.yml')
    #token = Openstack.openstack_token
    #puts token
    user = properties["OS_USERNAME"]
    password = properties["OS_PASSWORD"]
    tenant = properties["OS_TENANT"]
    auth_url = properties["OS_AUTH_URL"]
    openstack_swift_url = properties["openstack_swift_url"]
    put_url = "#{openstack_swift_url}/peel/#{noid}/#{file_type}/1#{extension}"
    put_location = "#{noid}/#{file_type}/1#{extension}"
    swift_cmd =  "swift upload -H \"X-Object-Meta-Peel: #{peelnum}\" peel #{file} --object-name=#{put_location}"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdin
    puts stdout
    puts stderr
  end

  def self.ingest_steele(file, metadata)
    checksum = Digest::MD5.hexdigest(file)
    size = File.size(file)
    noid = metadata['noid']
    steelenum = metadata['steelenum']
    extension = File.extname(file)
    if extension == ".tar"
      file_type = File.basename(file).split('.').first
    elsif extension == ".pdf"
      file_type = "pdf"
    end
    properties = YAML.load_file('properties.yml')
    user = properties["OS_USERNAME"]
    password = properties["OS_PASSWORD"]
    tenant = properties["OS_TENANT"]
    auth_url = properties["OS_AUTH_URL"]
    openstack_swift_url = properties["openstack_swift_url"]
    put_url = "#{openstack_swift_url}/steele/#{noid}/#{file_type}/1#{extension}"
    put_location = "#{noid}/#{file_type}/1#{extension}"
    swift_cmd =  "swift upload -H \"X-Object-Meta-Steele: #{steelenum}\" digitization #{file} --object-name=#{put_location}"
    puts swift_cmd
    stdin, stdout, stderr = Open3.capture3(swift_cmd)
    puts stdin
    puts stdout
    puts stderr
  end




  def self.openstack_token
    properties = YAML.load_file('properties.yml')
    openstack_credentials = properties['openstack_credentials']
    openstack_token_url = properties['openstack_token_url']
    curl_cmd = "curl -i -H \"Content-Type: application/json\" -d '#{openstack_credentials}' #{openstack_token_url}"
    puts curl_cmd
    stdin, stdout, stderr = Open3.capture3(curl_cmd)
    puts stdin
    response = "{" + stdin.split("{", 2)[1]
    response_hash = JSON.parse(response)
    return response_hash["access"]["token"]["id"]
  end

end
