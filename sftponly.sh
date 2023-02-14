#!/bin/bash

# check if user is running this script as root
if [ "$(id -u)" -ne 0 ]; then 
	echo "You need to run this script as root, exiting."
	exit 1
fi

usage() { echo "Usage: $0 -m <add|remove> [-u <string>] [-p <string>]" 1>&2; exit 1; }
[ $# -eq 0 ] && usage
while getopts "hm:u:p:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         m)
             MODE=$OPTARG
             ;;
         u)
             USERNAME=$OPTARG
             ;;
         p)
             PASSWORD=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

SSHDCONFIG=/etc/ssh/sshd_config
JAILGROUP=sftpusers
JAILHOME=/var/www/htdocs

# comment out original Subsystem and add Subsystem for internal-sftp
if grep -Fxq 'Subsystem sftp /usr/lib/openssh/sftp-server' $SSHDCONFIG; then
  sed -i 's/^[^#]*Subsystem sftp \/usr\/lib\/openssh\/sftp-server/#&/' $SSHDCONFIG
  echo "\nSubsystem sftp internal-sftp" >> $SSHDCONFIG
fi

# add jail rules for group
if ! grep -q "Match group $JAILGROUP" $SSHDCONFIG; then
  echo "
Match group $JAILGROUP
  ChrootDirectory %h
  AllowTCPForwarding no
  X11Forwarding no
  ForceCommand internal-sftp
" >> $SSHDCONFIG

service sshd restart
fi

if [[ -z $MODE ]]; then
  usage
  exit 1
fi

if [[ $MODE == "add" ]]; then
  if [[ -z $USERNAME ]] || [[ -z $PASSWORD ]]; then
    usage
    exit 1
	else 
		DOMAIN=$(sed 's/.*\.\(.*\..*\)/\1/' <<< $USERNAME)

		# check if given user exists
		if getent passwd $USERNAME &>/dev/null; then
			echo "User already exists, exiting."
			exit 1
		fi

		# check if JAILGROUP exists, if not create it
		if ! getent group $JAILGROUP &>/dev/null; then
			groupadd $JAILGROUP
		fi

		# check if JAILHOME exists, if not create it
		if [ ! -d "$JAILHOME" ]; then
			mkdir -p "$JAILHOME"
			chown root:sftpusers $JAILHOME
		fi

		# check if DOMAIN-dir exists, if not create it
		if [ ! -d "$JAILHOME/$DOMAIN/" ]; then
			mkdir -p "$JAILHOME/$DOMAIN/"
		fi

		# check if its only DOMAIN without sub-DOMAIN
		if [[ "$USERNAME" != "$DOMAIN" ]]; then
			USERHOME=$DOMAIN/$USERNAME
		else
			USERHOME=$DOMAIN
		fi

		# check if home with html dir exists, if not create it
		if [ ! -d "$JAILHOME/$USERHOME/html" ]; then
			mkdir -p "$JAILHOME/$USERHOME/html"
		fi

		# add user
		useradd -r -g $JAILGROUP -s /sbin/nologin -G www-data $USERNAME -d $JAILHOME/$USERHOME

		chown root:$JAILGROUP $JAILHOME/$USERHOME
		chmod 755 $JAILHOME/$USERHOME
		chown $USERNAME:$JAILGROUP $JAILHOME/$USERHOME/html
		chmod 775 $JAILHOME/$USERHOME/html

		# change to given password
		usermod --password $(echo $PASSWORD | openssl passwd -1 -stdin) $USERNAME

  fi
fi

if [[ $MODE == "remove" ]]; then
  if [[ -z $USERNAME ]]; then
    usage
    exit 1
	else
		DOMAIN=$(sed 's/.*\.\(.*\..*\)/\1/' <<< $USERNAME)
		
		# check if its only DOMAIN without sub-DOMAIN
		if [[ "$USERNAME" != "$DOMAIN" ]]; then
			USERHOME=$DOMAIN/$USERNAME
		else
			USERHOME=$DOMAIN
		fi

		if ! getent passwd $USERNAME &>/dev/null; then
			echo "User does not exist, exiting."
			exit 1
		fi

		# kill users session
		killall -u $USERNAME

		# delete user with his home directory
		userdel $USERNAME
		echo "Deleting $JAILHOME/$USERHOME"
		rm -rf $JAILHOME/$USERHOME
  fi
fi

