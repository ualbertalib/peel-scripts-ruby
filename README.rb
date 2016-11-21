# Peel-Ingest-Script with Ruby

This is a script written in Ruby to handle the ingest of digitized objects to OpenStack Swift.

### Available Variables:
* ```-t (or --resource-type)```: Type of resource is to be ingested (peelbib, newspaper, generic) - To be added: steele, airphotos etc.
* ```-dry (or --dry-run)```: To test run the script without updating database or ingesting into storage
* ```-d (or --directory)```: Directory that need to be ingested
* ```-l (or --file-list)```: The script will generate a complete list of all files in the delivery with MD5 hashes in the directory: deliveries/. This is the filename of the list
* ```-delivery```: This is the delivery number that this ingest batch will be logged in the database
* ```-drive (or --drive-id)```: This is the last four digits of the hard drive ID this delivery is on.
* ```-p (or --publication)```: This is the three digit publication code for newspapers and magazines
* ```-c (or --collection)```: Collection name that this ingest batch belongs to, it's used for generic digitized materials
* ```-b (or --skipbag)```: Skip checking bags if the delivery is a valid bag. '

### Usage
In order to use the script, the workstation running the script need to have ruby installed, and run
```
bundle install
```
to install all the necessary ruby gems.
check the Gemfile and install gem needed by
```
sudo gem install ddr-antivirus
```
to make clamdscan work, run the following code
```
sudo apt-get install clamav clamav-daemon
```
And database.yml.template and properties.yml.template need to be updated with valid access information

To ingest newspaper:
```
ruby ingest.rb -t newspaper -d /The_drive/ShipmentSample/ -p LEM -delivery westcan-frenews -drive 2648 -l deliveries/westcan-lem.xml
```

To ingest peelbib:
```
ruby ingest.rb -t peelbib -d /The_drive/ShipmentSample/ -drive 8093 -l deliveries/shipmentSample.xml -delivery bkstg0036
```

### To-Do
* To documenent the details to run the script.
* To ingest Steele materials
* Complete the documentation for ingesting the generic objects.
