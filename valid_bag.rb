  #Validate bag
require 'logger'
require 'bagit'
def validate_bag(dir)
  bag = BagIt::Bag.new dir
  return bag.valid?
end


dir="/media/baihong/Didsbury/Output/Didsbury/DidsburyR/"
timestamp = Time.now.to_s.tr(" ", "_")
last_dir = dir.split("/").last
logfile = "log/local-#{last_dir}-#{timestamp}"
puts logfile
logger = Logger.new(logfile)
logger.info "Start Ingest the directory #{dir}"
logger.info "Start to valid bags in the delivery"
bagcount = Dir.glob(dir+"/**/bagit.txt").count
logger.info "Validate #{bagcount} bag directories in the delivery"
validate_bag(dir)
Dir.glob(dir+"/**/bagit.txt") do |f|
  d = File.dirname(f)
  bag_valid = validate_bag(d)
  if bag_valid
    logger.info "Directory #{d} is a valid bag"
    FileUtils.touch (d +'/bag_verified')
  else
    logger.error "Directory #{d} is not a valid bag, view log files for more detailed information"
    FileUtils.touch (d+'/bag_not_verified')
  end
end
puts "bag finish"
