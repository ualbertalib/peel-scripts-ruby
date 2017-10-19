# Dir.glob("/home/baihong/Documents/user/user/**/*.tar") do |f|
#   puts f
#   path=File.dirname(f)
#   puts path
#   v1=%x(cd #{path};tar -xvf 1.tar)
#   puts v1
# end


require 'optparse'
require 'fileutils'
require 'bagit'
def create_bag(target_dir, files, full_path)
  bag = BagIt::Bag.new target_dir
  files.each do |f|
    File.open(f) do |rio|
      if full_path
        file_path = f.gsub!(/[^0-9A-Za-z.\-]/, '_')
      else
        file_path = File.basename(f)
      end
        begin
          bag.add_file(file_path) {|io| io.write rio.read }
        rescue Exception => e
          cleanup(target_dir)
          retry
       end
    end
  end
  bag.manifest!
end

options = {}
  OptionParser.new do |opts|
    opts.on("-f", "--directory FOLDER", "Directory that need to be ingested") do |v|
        options[:directory] = v
      end
    end.parse!
  dir = options[:directory]
  p dir
  target_dir=File.join(dir, 'PDF')
  puts target_dir
  files=Dir.glob("#{dir}/**/*.pdf")
  FileUtils::mkdir_p target_dir
  create_bag(target_dir, files, false)
