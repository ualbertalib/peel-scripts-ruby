'''
This Program helps to download 'mets' and 'aldo' (can further change)
for each individual issue of the newspaper from the OpenStack Swift
to the accessinn ftp server, and put them into 'uploads/production'
folder on the ftp server with name format of
    <Newspaper code>-<Year><Month><Day><unique ID>
Example:
    RRA-1999020301
Unique ID is set to '01' for the most case. If multiple papers in
the database have the same code, year, month and day, then assign
them with different unique ID, increment from 1.

Run this code on jeoffry server by
    python3 swift_to_accessinn.py
'''
from mysql.connector import connect
from ftplib import FTP_TLS
import subprocess
from uuid import uuid4
import os

language_abbrev_map = {"en": "english", "fr": "french"}


def ftp_upload():
    # Generate a temp folder, make sure the folder not in use
    while True:
        temp_folder = "~/temp_" + str(uuid4())
        if not os.path.isdir(temp_folder):
            break
    subprocess.run(["mkdir", temp_folder])

    # Connect to FTP server of the Access Innovations
    ftps = FTP_TLS()
    ftps.connect("ftp.accessinn.com")
    ftps.sendcmd("USER <username>")
    ftps.sendcmd("PASS <password>")
    ftps.cwd("uploads/production")
    language_folder = ftps.nlst()
    processed_news = dict()

    # Generate language folders
    for language in ("english", "french"):
        processed_news[language] = list()
        if language not in language_folder:
            ftps.mkd(language)
            ftps.mkd(language + "/combined")
            ftps.mkd(language + "/separate")
        else:
            ftps.cwd("%s/separate" % language)
            processed_news[language] = ftps.nlst()
            ftps.cwd("../..")

    # Get noids
    cnx = connect(host="<host>",
                  database="<db>",
                  user="<username>",
                  password="<password>",
                  port="<port>",
                  charset='utf8',
                  use_pure=True)

    cursor = cnx.cursor()

    # Count number of newspapers that need to transmit
    query = ("SELECT COUNT(noid) FROM  <db>.newspapers WHERE newspaper IN " +
             "('RRA', 'SCN', 'WTM', 'LMT', 'PDW', 'CVC', 'GAT', 'DBR', 'COL', 'LPM', 'LEQ', 'LMT', 'LEM', 'LUN', " +
             "'GGG', 'LEP', 'UNI') AND noid IS NOT NULL")
    cursor.execute(query)
    total_newspaper = cursor.fetchall()[0][0]

    # Get information of newspapers that need to transmit
    query = ("SELECT noid, newspaper, year, month, day, language FROM  <db>.newspapers WHERE newspaper IN " +
             "('RRA', 'SCN', 'WTM', 'LMT', 'PDW', 'CVC', 'GAT', 'DBR', 'COL', 'LPM', 'LEQ', 'LMT', 'LEM', 'LUN', " +
             "'GGG', 'LEP', 'UNI') AND noid IS NOT NULL")
    cursor.execute(query)

    current_count = 0
    for data in cursor:
        current_count += 1
        noid, news_abbrev, year, month, day, language = data
        counter = 1

        try:
            # For now, always put into 'separate' folder, but need to put into different language folder
            ftps.cwd("%s/separate" % language_abbrev_map[language])
            # while True:
            #     upload_folder_name = "%s-%d%02d%02d%02d" % (news_abbrev, year, month, day, counter)
            #     if upload_folder_name not in processed_news[language_abbrev_map[language]]:
            #         break
            #     counter += 1

            upload_folder_name = "%s-%d%02d%02d%02d" % (news_abbrev, year, month, day, counter)
            if upload_folder_name in processed_news[language_abbrev_map[language]]:
                ftps.cwd("../..")
                print("%s already exist on server. NOID: %s" % (upload_folder_name, noid))
                continue

            # Generate folders on FTP server
            # Download from OpenStack Swift, upload to FTP server
            ftps.mkd(upload_folder_name)
            for target_folder in ("mets", "alto"):
                print("Transmitting %s/%s, work done: %d out of %d %.2f%%" % (upload_folder_name, target_folder,
                                                                              current_count, total_newspaper,
                                                                              100 * current_count / total_newspaper))
                ftps.mkd("%s/%s" % (upload_folder_name, target_folder))
                subprocess.run(["swift", "download", "newspapers", "%s/%s/1.tar" % (noid, target_folder),
                                "-o", "%s/1.tar" % temp_folder])
                with open("%s/1.tar" % temp_folder, "rb") as transmit_file:
                    ftps.storbinary("STOR %s/%s/1.tar" % (upload_folder_name, target_folder), transmit_file)
                subprocess.run(["rm", "-f", "%s/1.tar" % temp_folder])

            # Get back to the production folder to reselect the language
            ftps.cwd("../..")
        except:
            ftps.cwd("~/uploads/production")
            with open("%s_errorlog.txt" % temp_folder, 'w') as error_log:
                print("Error occurs when transmitting %s." % noid)
                error_log.write("Error occurs when transmitting %s.\n" % noid)

    cnx.close()
    ftps.close()

    # Clean up temporary folder
    subprocess.run(["rm", "-r", temp_folder])


if __name__ == '__main__':
    ftp_upload()
