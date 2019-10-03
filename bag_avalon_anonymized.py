'''
This Program helps to download all media files (can further change)
from the avalon server, create bag for each individual file, then
upload to the OpenStack Swift (Avalon version) with its unique noid,
and finally update the database.

Set variables between line 27 to line 52 and run the code locally,
then the process should automatically do its job.
    python3 bag_avalon_anonymized.py
'''
import datetime
import sys
import shutil
import bagit
from uuid import uuid4
import os
import subprocess
import tarfile
import paramiko
import hashlib
import urllib.request
from stat import S_ISDIR

python_print = print
video_audio_extension = ['wav', 'mov', 'MP4', 'flac', 'mp3', 'aiff', 'm4v', 'flv', 'MP3', 'mp4']

user = "<Removed>"  # Your username on the local machine
checksum = "<Removed>"  # A tuple of checksums

swift_login = "<Removed>"  # should be avalon setting

server_address = "<Removed>"
server_username = "<Removed>"
server_port = 0
noid_minter = "<Removed>"
db_table_name = "<Removed>"
delivery = "<Removed>"

sftp_host = "<Removed>"
sftp_port = 0
sftp_username = "<Removed>"
sftp_password = "<Removed>"
sftp_folder = "<Removed>"

error_log_name = "errorlog"

processed_files = []
finish_count = 0
total_counter = 0
skip_count = 0
start_time = datetime.datetime.now()
previous_time = start_time

if os.path.isfile("/home/%s/Documents/success_info.sql" % user):
    with open("/home/%s/Documents/success_info.sql" % user, 'r') as sql_file:
        for sql_line in sql_file:
            elements = sql_line.strip('\n').split("'")
            processed_files.append(elements[3])


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


def md5(file_name):
    hash_md5 = hashlib.md5()
    hash_sha2 = hashlib.sha256()

    with open(file_name, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
            hash_sha2.update(chunk)

    return hash_md5.hexdigest(), hash_sha2.hexdigest()


def bag_upload(full_path, file_name):
    # Create Bag
    print(f"Bagging {file_name} with checksum {checksum}", color=[92])
    bag = bagit.make_bag("%s/tmp" % temp_folder, checksums=checksum)
    bag.save()

    # Get noid
    with urllib.request.urlopen(noid_minter) as response:
        html = response.read()
        noid = html.decode()[4:].strip('\n')
    print(f"Noid assigned for {file_name} is {noid}", color=[92])
    tar_dir = f"{temp_folder}/{noid}"
    os.mkdir(tar_dir)

    # Tar bag
    with tarfile.open("%s/1.tar" % tar_dir, mode="w:") as archive:
        archive.add("%s/tmp" % temp_folder, arcname='')

    # Upload to Jeoffry
    print(f"Uploading {file_name} to Jeoffry", color=[92])
    return_value = subprocess.run(["scp", "-r", tar_dir,
                                   f"{server_username}@{server_address}:/home/{server_username}/"],
                                  stdout=subprocess.PIPE)
    if return_value.returncode:
        print(f"Error - Failed to upload {file_name} to jeoffry", color=[5, 91])
        with open(f"/home/{user}/Documents/{error_log_name}", 'a') as errorlog:
            errorlog.write(f"Error - Failed to upload to jeoffry - {file_name}\n")
        return

    # Upload to openStack Swift
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=server_address,
                   port=server_port,
                   username=server_username,
                   timeout=2)
    print(f"Uploading {file_name} to Swift", color=[92])
    stdin, stdout, stderr = client.exec_command("swift %s upload era_av %s" %
                                                (swift_login, noid), get_pty=True)
    stdout.channel.recv_exit_status()
    for line in stdout:
        print(line.strip('\n'))
    stdin, stdout, stderr = client.exec_command("rm -rf %s" % noid, get_pty=True)
    stdout.channel.recv_exit_status()
    for line in stdout:
        print(line.strip('\n'))
    client.close()

    md5_code, sha2_code = md5("%s/1.tar" % tar_dir)
    file_size = os.path.getsize("%s/1.tar" % tar_dir)
    prefix = f"./{sftp_folder}/"
    full_path = full_path.replace(prefix, '').split('/')
    k1 = "'"
    k2 = "\\'"
    with open(f"/home/{user}/Documents/success_info.sql", 'a') as sql_insert:
        sql_insert.write(f"INSERT INTO {db_table_name} "
                         f"(<Removed>)"
                         f" VALUES "
                         f"('{noid}', '{file_name}', '{full_path[0].replace(k1, k2)}',"
                         f"'{delivery}', '{md5_code}', '{sha2_code}',"
                         f"'{file_size}', '1', '{'/'.join(full_path[1:]).replace(k1, k2)}');\n")

    print(f"Successfully upload {file_name} to OpenStack Swift with noid {noid}", color=[92])
    shutil.rmtree("%s/tmp" % temp_folder)
    shutil.rmtree(tar_dir)


def download_recursively(sftp, current_path):
    global finish_count, skip_count, previous_time
    for entry in sftp.listdir_attr(current_path):
        current_entry = f"{current_path}/{entry.filename}"
        if S_ISDIR(entry.st_mode):
            download_recursively(sftp, current_entry)
        else:
            if entry.filename.split('.')[-1].lower() in video_audio_extension and entry.filename[0] not in "_~":
                if entry.filename in processed_files:
                    print(f"{entry.filename} uploaded before, skip", color=[94])
                    skip_count += 1
                    continue

                prefix = f"./{sftp_folder}/"
                print(f"{entry.filename} found. Start processing.", color=[104])
                print(f"Downloading {entry.filename} from collection {current_path.replace(prefix, '')}", color=[92])
                os.mkdir(f"{temp_folder}/tmp/")
                sftp.get(current_entry, f"{temp_folder}/tmp/{entry.filename}")
                bag_upload(current_path, entry.filename)

                finish_count += 1
                current_time = datetime.datetime.now()

                progress = f"{finish_count} out of {total_counter} ({finish_count * 100 / total_counter:.2f}%)"
                max_len = len(progress) + 10
                print(f"{'=' * (max_len + 26)}", color=[1, 7, 93])
                print(f"   Current time is:       ", end='', color=[1, 7, 93])
                print(f"{current_time}", color=[7, 93], fit_len=max_len)
                print(f"   Current progress:      ", end='', color=[1, 7, 93])
                print(f"{progress}", color=[7, 93], fit_len=max_len)
                current_run_time = current_time - start_time
                current_progress_perc = (finish_count - skip_count) / (total_counter - skip_count)
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
            else:
                print(f"{entry.filename} not a recongnized video/audio file, or it is a temp file, skip", color=[95])
                skip_count += 1
                finish_count += 1


def count_files(sftp, current_path):
    global total_counter
    for entry in sftp.listdir_attr(current_path):
        current_entry = f"{current_path}/{entry.filename}"
        if S_ISDIR(entry.st_mode):
            count_files(sftp, current_entry)
        else:
            total_counter += 1


def main():
    sf = paramiko.Transport((sftp_host, sftp_port))
    sf.connect(username=sftp_username, password=sftp_password)
    with paramiko.SFTPClient.from_transport(sf) as sftp:
        count_files(sftp, f"./{sftp_folder}")
        download_recursively(sftp, f"./{sftp_folder}")


def test():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=server_address,
                   port=server_port,
                   username=server_username,
                   timeout=2)
    stdin, stdout, stderr = client.exec_command(f"swift {swift_login} stat test", get_pty=True)
    print(stdout.readlines())


if __name__ == '__main__':
    while True:
        temp_folder = uuid4()
        if not os.path.isdir("~/Documents/temp_%s" % temp_folder):
            os.mkdir("/home/%s/Documents/temp_%s" % (user, temp_folder))
            break

    temp_folder = "/home/%s/Documents/temp_%s" % (user, temp_folder)
    main()
    shutil.rmtree(temp_folder)
