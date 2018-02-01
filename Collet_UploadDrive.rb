require "google_drive"
session = GoogleDrive::Session.from_config("client_secret.json")
count1=0
count2=0
Dir.glob("/media/baihong/My\ Passport/news/va2/VA_1956-1960/**/VA_*.pdf") do |f|
    puts f
    issuename = File.basename(f)
    puts issuename
    if (file = session.file_by_title("#{issuename}"))
      count1=count1+1
      p "#{count1}: #{issuename} is in GoogleDrive"
      session.root_collection.remove(file)
    else
      count2=count2+1
      p "#{count2}: #{issuename} is NOT in GoogleDrive"
      file_to_upload=session.upload_from_file("#{f}", "#{issuename}", convert: false)
      folder = session.collection_by_title("vulcan")
      folder.add(file_to_upload)
      session.root_collection.remove(file_to_upload)
      puts "#{issuename} uploaded to Google Drive"
    end
    # file=session.upload_from_file("#{f}", "#{issuename}", convert: false)
    # folder = session.collection_by_title("vulcan")
    # folder.add(file)
    # puts "#{issuename} uploaded to Google Drive"
end
