# sftponly
Creates a new user who is allowed to connect via SFTP only and is chrooted in his directory.

# Prerequisites
- Debian system for target machine
- SFTP client ([WinSCP](https://winscp.net/), [FileZilla](https://filezilla-project.org/download.php?platform=win64), ...)

# Setup
Clone the repository onto the debian machine, that should host the files.

```
git clone https://github.com/WildDevs/sftponly
```

Change to root to be able to run the command and make the script executable.

```
sudo su
chmod +x ./sftponly/sftponly.sh
```

# Managing users

When creating a user with sftponly, it creates a standard linux user on the machine, that will be able to access a specifically created directory.
This user also can't use SSH to log into the machine itself.

Create a user and assign a password (make sure to do this as root).

```
./sftponly.sh -m add -u user -p password
```

You can also remove a user again with the script, you don't need to supply the password.

```
./sftponly.sh -m remove -u user
```

**CAUTION:**
Deleting a user will remove and delete the directory and all files inside associated with that user.
So make sure to make a copy of the files beforehand if needed!

# Connecting using the credentials and transferring files
Open your SFTP client and connect using the IP address of the debian machine on port 22.
Enter your credentials, that you set up earlier.

![image](https://user-images.githubusercontent.com/109043823/218782617-b7d8ced2-4016-4f87-83b2-2854a4fc843a.png)

Once the connection is established, you will be able to safely transfer files into the html directory of the folder.

![image](https://user-images.githubusercontent.com/109043823/218783841-520ce157-2842-4968-9ce0-5da3e10893f6.png)

The most important part is, that the connecting user is in a jail and can't leave the directory.

# Accessing Files Locally
If you want to access these files locally with your actual linux user, you need to add it to the `sftpusers` group.

```
usermod -aG sftpusers <user>
```

Then navigate to /var/www/htdocs/<user>/html.