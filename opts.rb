require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on("-t", "--resource-type TYPE", "Type of resource is to be ingested (peelbib,newspaper, image, steele, other)") do |v|
    options[:resource_type] = v
  end
  opts.on("-r", "--[no-]dry-run", "Dry run of the ingest") do |v|
    options[:dry_run] = v
  end
  opts.on("-d", "--directory DIR", "Directory that need to be ingested") do |v|
    options[:directory] = v
  end
  opts.on("-l", "--file-list LIST", "File name of the file list output") do |v|
    options[:file_list] = v
  end
  opts.on("-a", "--delivery DELIVERY", "Delivery number that this ingest batch will be logged in the database") do |v|
    options[:delivery] = v
  end
  opts.on("-v", "--drive-id ID", "last four digits of the hard drive ID this delivery is on") do |v|
    options[:drive_id] = v
  end
  opts.on("-p", "--publication PUB", "Three digit publication code for newspaper and magazine") do |v|
    options[:publication] = v
  end
  opts.on("-c", "--collection COLL", "Collection name that this ingest batch belongs to") do |v|
    options[:collection] = v
  end
  opts.on("-b", "--[no-]skipbag", "Skip checking if the delivery is a valid bag") do |v|
    options[:skipbag] = v
  end



end.parse!

p options
