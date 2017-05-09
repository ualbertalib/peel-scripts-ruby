require 'bagit'
require 'optparse'

number = 0
Dir.glob("/media/baihong/UALBERTA2418/GGG_BagIts/**/manifest-md5.txt") do |d|
  p d
  object_path = File.dirname(d)
  #puts object_path
  number = number +1
  begin
  bag = BagIt::Bag.new object_path
  if bag.valid?
  puts "No: #{number}: #{object_path} is valid"
else
  puts "No: #{number}: #{object_path} is not valid"
end
  rescue
    puts "No: #{number}: #{object_path} not supported"
  end

end

# object_path="/media/baihong/UA\ Digital_init\ 9375/generic/Rutherford/69.164.2.2.3.4.2.3"
# bag = BagIt::Bag.new object_path
# if bag.valid?
# puts "#{object_path} is valid"
# else
# puts "#{object_path} is not valid"
# end


# options = {}
# OptionParser.new do |opts|
#   opts.on("-t", "--resource-type TYPE", "Type of resource is to be ingested (peelbib,newspaper, image, steele, other)") do |v|
#     options[:resource_type] = v
#   end
#   opts.on("-r", "--[no-]dry-run", "Dry run of the ingest") do |v|
#     options[:dry_run] = v
#   end
#   opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
#     options[:directory] = v
#   end
#   opts.on("-l", "--file-list LIST", "File name of the file list output") do |v|
#     options[:file_list] = v
#   end
#   opts.on("-d", "--delivery DELIVERY", "Delivery number that this ingest batch will be logged in the database") do |v|
#     options[:delivery] = v
#   end
#   opts.on("-i", "--drive-id ID", "last four digits of the hard drive ID this delivery is on") do |v|
#     options[:drive_id] = v
#   end
#   opts.on("-p", "--publication PUB", "Three digit publication code for newspaper and magazine") do |v|
#     options[:publication] = v
#   end
#   opts.on("-c", "--collection COLL", "Collection name that this ingest batch belongs to") do |v|
#     options[:collection] = v
#   end
#   opts.on("-b", "--[no-]skipbag", "Skip checking if the delivery is a valid bag") do |v|
#     options[:skipbag] = v
#   end
# end.parse!
# p options
# timestamp = Time.now.to_s.tr(" ", "_")
# dir = options[:directory]
# file_list = options[:file_list]
# last_dir = dir.split("/").last
# type = options[:resource_type]
# dryrun = options[:dry_run]
# collection = options[:collection]
# skip_bag = options[:skipbag]
# logfile = "log/local-#{last_dir}-#{timestamp}"
# logger = Logger.new(logfile)
# logger.info "Start Ingest the directory #{dir}"
#
# #Validate bag
# unless skip_bag
#   logger.info "Start to valid bags in the delivery"
#   bagcount = Dir.glob(dir+"/**/bagit.txt").count
#   logger.info "Validate #{bagcount} bag directories in the delivery"
#   validate_bag(dir)
#   Dir.glob(dir+"/**/bagit.txt") do |f|
#     d = File.dirname(f)
#     bag_valid = validate_bag(d)
#     if bag_valid
#       logger.info "Directory #{d} is a valid bag"
#       FileUtils.touch (d +'/bag_verified')
#     else
#       logger.error "Directory #{d} is not a valid bag, view log files for more detailed information"
#       FileUtils.touch (d+'/bag_not_verified')
#     end
#   end
#   puts "bag finish"
# end
