import bagit
import glob
import shutil
from uuid import uuid4
import os
import subprocess
import tarfile
import paramiko
import hashlib
import urllib.request


def md5(file_name):
    hash_md5 = hashlib.md5()
    hash_sha2 = hashlib.sha256()

    with open(file_name, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
            hash_sha2.update(chunk)

    return hash_md5.hexdigest(), hash_sha2.hexdigest()


def main():
    user = "<REMOVED>"  # Machine login user
    media = "<REMOVED>"  # HDD name
    main_folder = "<REMOVED>"  # Folder in HDD
    sub_folder = ("<REMOVED>",)  # Target folders in main_folder
    checksum = ("md5",)

    # Swift login info, can be found on the server
    swift_login = "--os-project-domain-name <REMOVED>" \
                  " --os-user-domain-name <REMOVED>" \
                  " --os-project-name <REMOVED>" \
                  " --os-username <REMOVED>" \
                  " --os-password <REMOVED>" \
                  " --os-auth-url <REMOVED>" \
                  " --os-identity-api-version <REMOVED>"

    server_address = "<REMOVED>"
    server_username = "<REMOVED>"
    server_port = None
    noid_minter = "<REMOVED>"
    db_table_name = "<REMOVED>"
    collection = "<REMOVED>"

    while True:
        temp_folder = uuid4()
        if not os.path.isdir("~/Documents/temp_%s" % temp_folder):
            os.mkdir("/home/%s/Documents/temp_%s" % (user, temp_folder))
            break

    temp_folder = "/home/%s/Documents/temp_%s" % (user, temp_folder)

    # Get successed files
    processed_files = {}
    for folder in sub_folder:
        processed_files[folder] = list()
    if os.path.isfile("/home/%s/Documents/success_info.sql" % user):
        with open("/home/%s/Documents/success_info.sql" % user, 'r') as file:
            for line in file:
                elements = line.strip('\n').split("'")
                processed_files[elements[7]].append(elements[3])

    for i, folder in enumerate(sub_folder):
        all_file = [file for file in glob.glob("/media/%s/%s/%s/*.tif" %
                                               (user, media, main_folder + folder))]
        for j, process_file in enumerate(all_file):

            prefix = process_file[:process_file.rindex('/')]
            file_name = process_file[process_file.rindex('/') + 1:process_file.rindex('.')]

            if file_name in processed_files[folder]:
                print("%s/%s already uploaded, skip the file" % (folder, file_name))
                continue

            files = ("%s/%s.tif" % (prefix, file_name),
                     "%s/MODS/%s.xml" % (prefix, file_name))

            os.mkdir("%s/tmp" % temp_folder)

            error_check = False
            for file in files:
                if not os.path.isfile(file):
                    print("Error - file %s not found" % file)
                    with open("/home/%s/Documents/errorlog.txt" % user, 'a') as errorlog:
                        errorlog.write("Error - file not found - %s\n" % file)
                    error_check = True
            if error_check:
                continue

            # Copy to temp folder
            for file in files:
                shutil.copy(file, "%s/tmp" % temp_folder)
            # Create Bag
            bag = bagit.make_bag("%s/tmp" % temp_folder, checksums=checksum)
            bag.save()
            # Get noid
            with urllib.request.urlopen(noid_minter) as response:
                html = response.read()
                noid = html.decode()[4:].strip('\n')
            os.mkdir("%s/%s" % (temp_folder, noid))
            tar_dir = "%s/%s" % (temp_folder, noid)
            # Tar bag
            with tarfile.open("%s/1.tar" % tar_dir, mode="w:") as archive:
                archive.add("%s/tmp" % temp_folder, arcname='')

            # Upload to server
            return_value = subprocess.run(["scp", "-r", tar_dir, "%s@%s:/home/%s/" %
                                           (server_username, server_address, server_username)],
                                          stdout=subprocess.PIPE)
            if return_value.returncode:
                print("Error - Failed to upload %s to jeoffry" % file_name)
                with open("/home/%s/Documents/errorlog.txt" % user, 'a') as errorlog:
                    errorlog.write("Error - Failed to upload to jeoffry - %s\n" % file_name)
                continue

            # Upload to openStack Swift
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(hostname=server_address,
                           port=server_port,
                           username=server_username,
                           timeout=2)
            stdin, stdout, stderr = client.exec_command("swift %s upload digitization %s" %
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
            with open("/home/%s/Documents/success_info.sql" % user, 'a') as sql_insert:
                sql_insert.write("INSERT INTO %s "
                                 "(noid, object_name, collection, delivery, md5, sha2, file_size, file_count)"
                                 " VALUES "
                                 "('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n" %
                                 (db_table_name,
                                  noid, file_name, collection, folder, md5_code, sha2_code, file_size, 2))
            print("Successfully upload %s to OpenStack Swift with noid %s" % (file_name, noid))
            print("Folder: %d/%d, File: %d/%d (%.2f%%): %s" %
                  (i + 1, len(sub_folder), j + 1, len(all_file),
                   100 * (i / len(sub_folder) + (j + 1) / (len(all_file) * len(sub_folder))),
                   folder + '/' + file_name))
            shutil.rmtree("%s/tmp" % temp_folder)
            shutil.rmtree(tar_dir)

    shutil.rmtree(temp_folder)


if __name__ == '__main__':
    main()
