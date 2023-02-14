# sftponly
Creates a new user who is allowed to connect via SFTP only and is chrooted in his directory.

# Prerequisites
- Debian system for target machine
- SFTP client (WinSCP, FileZilla, ...)

# How to use
This contains 2 steps: Setting up a user to be able to connect with and connecting with said user's credentials.

## Creating a user
Clone the repo onto the debian machine, that should host the files.

```
git clone https://github.com/WildDevs/sftponly
```
Change to root to be able to run the command and make the script executable.

```
sudo su
chmod +x /sftponly/sftponly.sh
```

Create a user and assign a password.

```
sh sftponly.sh -m add -u user -p password
```

## Connecting using the credentials and transferring files
Download an SFTP client for example [WinSCP](winscp.net/).

Open your client and connect using the IP address of the debian machine on port 22.
Enter your credentials, that you set up earlier.

![image](https://user-images.githubusercontent.com/109043823/218782617-b7d8ced2-4016-4f87-83b2-2854a4fc843a.png)

Once the connection is established, you will be able to safely transfer files into the html directory of the folder.

![image](https://user-images.githubusercontent.com/109043823/218783841-520ce157-2842-4968-9ce0-5da3e10893f6.png)

These files can be accessed locally inside of /var/www/htdocs/<user>/html.

The most important part is, that the connecting user is in a jail and can't leave the directory.
