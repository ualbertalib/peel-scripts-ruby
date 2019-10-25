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
from ftplib import FTP_TLS, error_perm
import subprocess
from uuid import uuid4
import os
import sys
import datetime

language_abbrev_map = {"en": "english", "fr": "french"}
transmit_folder_list = ("mets", "alto")

ftp_address = "ftp.accessinn.com"
ftp_username = "<REMOVED>"
ftp_password = "<REMOVED>"
ftp_upload_folder = "uploads/production"

db_address = "<REMOVED>"
db_database = "<REMOVED>"
db_username = "<REMOVED>"
db_password = "<REMOVED>"
db_port = 0  # REMOVED

swift_login = ["--os-project-domain-name", "<REMOVED>",
               "--os-user-domain-name", "<REMOVED>",
               "--os-project-name", "<REMOVED>",
               "--os-username", "<REMOVED>",
               "--os-password", "<REMOVED>",
               "--os-auth-url", "<REMOVED>",
               "--os-identity-api-version", "<REMOVED>"]


python_print = print


def print(*objects, sep=' ', end='\n', file=sys.stdout, color=(), fit_len=-1):
    line = "".join(map(str, objects))
    fit_len = max(fit_len - len(line), 0)

    for c in color:
        if len(objects) > 1:
            objects = (f"\033[{c}m{objects[0]}",) + objects[1:-1] + (
                f"{objects[-1]}{' ' * fit_len}\033[0m",)
        elif len(objects) == 1:
            objects = (f"\033[{c}m{objects[0]}{' ' * fit_len}\033[0m",)
    python_print(*objects, sep=sep, end=end, file=file)


def remove_folder(ftps, folder):
    ftps.cwd(f"{folder}")
    all_files = ftps.nlst()
    for file_dir in all_files:
        try:
            ftps.cwd(file_dir)
            ftps.cwd("..")
            remove_folder(ftps, file_dir)
        except error_perm:
            ftps.delete(file_dir)
    ftps.cwd("..")
    ftps.rmd(f"{folder}")


def try_make_dir(ftps, folder):
    try:
        ftps.mkd(folder)
    except error_perm:
        pass


def compare_size(ftps, noid, filename, folder):
    try:
        on_swift = int(subprocess.run(
            ["swift", *swift_login, "stat", "newspapers", f"{noid}/{folder}/1.tar"],
            stdout=subprocess.PIPE).stdout.decode().split('\n')[4].split(':')[1])
        on_server = int(ftps.size(f"{filename}/{folder}/1.tar"))
        return True, on_server == on_swift
    except (IndexError, error_perm) as e:
        return False, e


def ftp_upload():
    # Generate a temp folder, make sure the folder not in use
    while True:
        temp_folder = "~/temp_" + str(uuid4())
        if not os.path.isdir(temp_folder):
            break
    subprocess.run(["mkdir", temp_folder])

    # Connect to FTP server of the Access Innovations
    ftps = FTP_TLS()
    ftps.connect(ftp_address)
    ftps.sendcmd(f"USER {ftp_username}")
    ftps.sendcmd(f"PASS {ftp_password}")
    ftps.cwd(ftp_upload_folder)

    # Generate language folders
    for language in language_abbrev_map.values():
        try_make_dir(ftps, language)
        try_make_dir(ftps, f"{language}/combined")
        try_make_dir(ftps, f"{language}/separate")

    # Get noids
    cnx = connect(host=db_address,
                  database=db_database,
                  user=db_username,
                  password=db_password,
                  port=db_port,
                  charset='utf8',
                  use_pure=True)

    cursor = cnx.cursor()

    # Count number of newspapers that need to transmit
    query = (f"SELECT noid, newspaper, year, month, day, language FROM  peel_blitz.newspapers WHERE newspaper IN " +
             f" {tuple(sys.argv[1:] + [''])} AND noid IS NOT NULL AND mounted = 0")
    cursor.execute(query)

    temp_sql_result = cursor.fetchall()
    cnx.close()

    start_time = datetime.datetime.now()
    previous_time = start_time
    fail_count = 0
    finish_count = 0
    skip_count = 0
    total = len(temp_sql_result)

    # Resolve issues happens in the same day
    counter_dict = dict()
    for i, data in enumerate(temp_sql_result):
        noid, news_abbrev, year, month, day, language = data
        upload_folder_name = "%s-%d%02d%02d" % (news_abbrev, year, month, day)
        counter_dict[upload_folder_name] = counter_dict.get(upload_folder_name, 0) + 1
        temp_sql_result[i] = data + (counter_dict[upload_folder_name],)
    del counter_dict

    for data in cursor:
        finish_count += 1
        noid, news_abbrev, year, month, day, language, counter = data
        upload_folder_name = "%s-%d%02d%02d%02d" % (news_abbrev, year, month, day, counter)

        try:
            # For now, always put into 'separate' folder, but need to put into different language folder
            ftps.cwd("%s/separate" % language_abbrev_map[language])

            print(f"Start processing {upload_folder_name}. NOID: {noid}", color=[42])

            # Generate folders on FTP server
            # Download from OpenStack Swift, upload to FTP server
            try_make_dir(ftps, upload_folder_name)
            all_skipped = True

            for target_folder in transmit_folder_list:
                try_make_dir(ftps, f"{upload_folder_name}/{target_folder}")

                # Check if the file is already on FTP server
                compare_result = compare_size(ftps, noid, upload_folder_name, target_folder)
                if compare_result[0] and compare_result[1]:
                    print(f"{upload_folder_name}/{target_folder}/1.tar already exist on server. NOID: {noid}",
                          color=[34])
                    continue

                # For new / different files, overwrite files on FTP server
                all_skipped = False
                print(f"Transmitting {upload_folder_name}/{target_folder}/1.tar")

                # Try to download from the OpenStack Swift server
                err = subprocess.run(
                    ["swift", *swift_login, "download", "newspapers",
                     f"{noid}/{target_folder}/1.tar", "-o", f"{temp_folder}/1.tar"],
                    stderr=subprocess.PIPE).stderr.decode()
                if err:
                    raise error_perm("File does not exist on Swift.")

                # Overwrite files on FTP server
                with open(f"{temp_folder}/1.tar", "rb") as transmit_file:
                    ftps.storbinary(f"STOR {upload_folder_name}/{target_folder}/1.tar", transmit_file)

                # Clean up
                subprocess.run(["rm", "-f", f"{temp_folder}/1.tar"])

            # Get back to the production folder to reselect the language for the next issue
            ftps.cwd("../..")

            # Log the success message
            with open("successlog.log", 'a') as success_log:
                print(f"Finined {upload_folder_name}. NOID: {noid}", color=[42])
                success_log.write(f"{noid}|{upload_folder_name}|Success\n")

            # For file that already on FTP, skip them
            if all_skipped:
                print(f"{upload_folder_name} already exist on server. NOID: {noid} ({finish_count}/{total})",
                      color=[34])
                skip_count += 1
                continue

        # Stop current transmission if error occurs
        except error_perm as e:
            ftps.cwd("~/uploads/production")
            fail_count += 1

            # Log the reason
            with open("errorlog.log", 'a') as error_log:
                print("Error occurs when transmitting %s." % noid, color=[5, 41])
                error_log.write(f"Error occurs when transmitting |{noid}|{upload_folder_name}|{e}\n")

        # Give a detailed program status analysis
        current_time = datetime.datetime.now()
        progress = f"{finish_count} out of {total} ({finish_count * 100 / total:.2f}%), {fail_count} failed"
        max_len = len(progress) + 10
        print(f"{'=' * (max_len + 26)}", color=[1, 7, 93])
        print(f"   Current time is:       ", end='', color=[1, 7, 93])
        print(f"{current_time}", color=[7, 93], fit_len=max_len)
        print(f"   Current progress:      ", end='', color=[1, 7, 93])
        print(f"{progress}", color=[7, 93], fit_len=max_len)
        current_run_time = current_time - start_time
        current_progress_perc = (finish_count - skip_count) / (total - skip_count)
        estimate_remain = current_run_time / current_progress_perc - current_run_time
        print(f"   Current total runtime: ", end='', color=[1, 7, 93])
        print(f"{current_run_time}", color=[7, 93], fit_len=max_len)
        print(f"   Last update runtime:   ", end='', color=[1, 7, 93])
        print(f"{current_time - previous_time}", color=[7, 93], fit_len=max_len)
        print(f"   Estimate remaining:    ", end='', color=[1, 7, 93])
        print(f"{estimate_remain}", color=[7, 93], fit_len=max_len)
        print(f"   Estimate finish time:  ", end='', color=[1, 7, 93])
        print(f"{current_time + estimate_remain}", color=[7, 93], fit_len=max_len)
        print(f"{'=' * (max_len + 26)}", color=[1, 7, 93])
        previous_time = current_time

    ftps.close()

    # Clean up temporary folder
    subprocess.run(["rm", "-r", temp_folder])


if __name__ == '__main__':
    ftp_upload()
