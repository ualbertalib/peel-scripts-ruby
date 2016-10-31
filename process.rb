require 'slop'
require './helpers'
require 'fileutils'


#This script is to process any given digitized object, with text, image, and indexing materials created

def newspaper_processing_backstage(opts, connection)
  timestamp = Time.now.to_s.tr(" ", "_")
  logfile = "log/process-#{timestamp}"
  logger = Logger.new(logfile)
  publication = opts[:publication]
  year = opts[:year]
  month = opts[:month]
  date = opts[:date]
  logger.info "Start Processing Newspaper #{publication}: #{year} #{month} #{date}"
  nil_value = "%"
  select = "SELECT noid, year, month, day, edition from newspapers where newspaper = '#{publication}' AND year LIKE '#{year || nil_value}' AND month LIKE '#{month || nil_value}' AND day LIKE '#{date || nil_value}';"
  puts select
  properties = Helpers.read_properties('properties.yml')
  temp_dir = properties['temp_dir']
  results = connection.query(select)
  results.each do |row| 
#   Openstack.retrieve_noid(row['noid'], 'newspapers')
    Dir.glob("**/1.tar").each do |f|
      outputdir = File.dirname(f)
      Utils.untar(f, outputdir)
    end
    metsfile = Dir.glob('**/mets/**/*-METS.xml').first
    altodir = File.dirname(Dir.glob("**/alto/**/*.xml").first)
    imagedir = File.dirname(Dir.glob("**/jp2/**/*.jp2").first)
    edition = row['edition']
    year ||= row['year']
    month ||= row['month']
    date ||= row['day']
    actmonth = "%.2d" % month
    actday = "%.2d" % date
    edition = "1" if row['edition'].nil? || row['edition'].empty?
    actedition = "%.2d" % edition
    targetdir = "#{temp_dir}/#{publication}/#{year}/#{actmonth}/#{actday}/#{actedition}"
    stagingdir = "#{temp_dir}/staging/#{publication}/#{year}/#{actmonth}/#{actday}/#{actedition}"
    logger.info "Processing to #{targetdir}"
    FileUtils.mkdir_p(targetdir) unless Dir.exist?(targetdir)
    FileUtils.mkdir_p(stagingdir) unless Dir.exist?(stagingdir)
    if File.exists?("#{targetdir}/processing")
      logger.error "Processing failed, possibly because directory #{targetdir} is locked by another process" 
    else
      FileUtils.touch("#{targetdir}/processing")
    end
    mets = Nokogiri::XML(File.read(metsfile))
    template = Nokogiri::XSLT(File.read('xsl/wcmets2build.xsl'))
    build_temp = template.transform(mets)
    File.open('build_temp.xml', 'w').write(build_temp)
 
    remove_processing_lock(targetdir)
    
    
  end
end

def remove_processing_lock(dir)
  FileUtils.rm("#{dir}/processing")
end



opts = Slop.parse do |o|
  o.string '-t', '--resource-type', 'Type of resource is to be processed (peelbib,newspaper, image, steele, other)'
  o.string '-v', '--vendor', 'The vendor where the digitization was done (backstage, westcan)'
  o.bool '-dry', '--dry-run', 'Dry run of the ingest'
  o.string '-p', '--publication', 'Three digit publication code for newspaper and magazine'
  o.string '-y', '--year', '4 digits publication year for newspaper and magazine, if not presented process all materials with the publication code'
  o.string '-m', '--month', '2 digits publication month, if not presented process all materials for the given publication year/code'
  o.string '-d', '--date', '2 digits publication date, if not presented process all materials for the given publication code/year/month'
  o.string '--image_scale_percent', 'we need to scale down the high-res images, this is the percentage it will scale down to, default 40', default: 40
  o.string '--page_display_percent', 'scale of full page image, after the image_scale_percent is applied', default: 50
end

puts opts.to_hash

type = opts[:resource_type]
dryrun = opts[:dry_run]
vendor = opts[:vendor]
connection = Helpers.set_mysql_connection
if type == "newspaper" && vendor == "backstage"
  newspaper_processing_backstage(opts, connection)
end
Helpers.close_mysql_connection(connection)

