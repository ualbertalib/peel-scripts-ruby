require './helpers'
require './lib/openstack/swift/connection.rb'

module Openstack

  def ingest_newspaper(file, metadata)
    checksum = Digest::MD5.hexdigest(file)
    size = File.size(file)
    publication = metadata['publication']
    year = metadata['year']
    month = metadata['month']
    day = metadata['day']
    edition = metadata['edition']
    extension = File.extname(file)
    file_type = File.dirname(file).split('/').last
    noid = Utils.noid
    put_url = URI::HTTP.build(:host => openstack_swift_url, :path => 'newspapers/#{noid}/#{file_type}/1.#{extension}')
    properties = YAML.load_file('properties.yml') 
    
    user = properties["OS_USERNAME"]
    password = properties["OS_PASSWORD"]
    tenant = properties["OS_TENANT"]
    auth_url = properties["OS_AUTH_URL"]

    swift = OpenStack::Connection.create({:username => user, :auth_url => auth_url, :authtenant => tenant, :api_key => password, :auth_method => "password", :service_type => "object-store"})

    container = swift.container('test')
    content = File.open('tmp/WHM_19040101/jp2.tar')
    new = container.create_object(noid, {:metadata=>{"peelnum" => "file"}}, content)
     
  end
end
