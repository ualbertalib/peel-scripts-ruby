require './helpers'
require 'fileutils'
FileUtils::mkdir_p 'foo/bar'

#phrase 1: download
def mysql_query(connection,query)
  begin
    rs = connection.query(query)
  rescue Exception => e
    raise e
    raise e if /Mysql::Error: Duplicate entry/.match(e.to_s)
  end
end

array=['PC000955','P011519','M000018','M000022','M000195','M000196','M000238','M000489','M000655','M000746','M000747','M000748','M000754']
#array=["PC013071","PC012486","PC012841","PC002734","PC013071","PC014166","PC013852","PC014129","PC012132","PC014195","PC014070","PC013869","PC013753","PC002901"]
connection = Helpers.set_mysql_connection
array.each do |item|
  cmd="select p.path, f.size, t.path from paths p, files f, tars t where p.id=f.path_id and f.tar_id=t.id and p.path like '%#{item}%' "
  # cmd='use pseudohoneycomb; select p.path, f.size, t.path from paths p, files f, tars t where p.id=f.path_id and f.tar_id=t.id and p.path like "%peel/geo/maps%M000524%tif%"'
  rs = mysql_query(connection, cmd)
  rs.each do |row|
          path=row['path']
          first=path.split("/")[2]
          second=path.split("/")[3]
          third=path.split("/")[4]
          newpath="/mnt/honeycomb/#{first}/#{second}/#{third}"
          folder_path="/home/baihong/Documents/user/peel_download/#{first}/#{second}"
          FileUtils::mkdir_p folder_path unless Dir.exist?(folder_path)
          if not File.exists?("#{folder_path}/#{third}")
            %x(scp baihong@preston.library.ualberta.ca:#{newpath} #{folder_path})
          end
          puts path
          puts newpath
      end
end
Helpers.close_mysql_connection(connection)



# test
# scp baihong@preston.library.ualberta.ca:/mnt/honeycomb/d20/d224/f151 /media/baihong/Documents/user/gat_news





#phrase 2: untar
  Dir.glob("/home/baihong/Documents/user/peel_download/**/f*") do |f|
    puts f
    issue_path = File.dirname(f)
    puts issue_path
    %x(tar -xvf #{f} -C "/home/baihong/Documents/user/peel")
  end
