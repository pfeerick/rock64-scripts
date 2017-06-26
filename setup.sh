#!/bin/bash

#halt script on first failure
set -e

#password="1YelloDog@" # your chosen password
#perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$password"

if [ "$(id -u)" -ne "0" ]; then
        echo "This script requires root."
        exit 1
fi

echo -en "Rock64 New Install Provisioning Script\n\n"

#import git credentials from server and load as $GIT_USERNAME and $GIT_EMAIL
wget -q http://192.168.0.5/provisioning/git-details && source git-details && rm git-details

echo -ne "Adding user 'pfeerick' ... "
useradd -m -p paYhAIkbtv3co -s /bin/bash -g pfeerick -G adm,sudo,video,plugdev,input,ssh pfeerick
echo -ne "done!\n"

echo -ne "Refreshing software update repositories ... "
apt-get update >/dev/null 2>&1
echo -ne "done!\n"

echo -ne "Fetching and installing any updates ... "
apt-get upgrade >/dev/null 2>&1
echo -ne "done!\n"

echo -ne "Fetching and installing network-manager ... "
apt-get install -y --no-install-recommends network-manager >/dev/null 2>&1
echo -ne "done!\n"

echo -ne "Fetching and installing typically wanted packages ... "
apt-get install -y --no-install-recommends htop screen >/dev/null 2>&1
echo -ne "done!\n"

echo -ne "Fixing locale issues resulting from en_AU.UTF-8 not being configured ... "
locale-gen en_AU.UTF-8
echo -ne "done!\n"

echo -ne "Restore SSH key backups from server ... "
sudo -u pfeerick mkdir /home/pfeerick/.ssh
wget -qO- 192.168.0.5/ssh-backup/rock64.tar.gz | tar -zxf - -C /
sudo -u pfeerick wget -qO "/home/pfeerick/.ssh/authorized_keys" 192.168.0.5/ssh-backup/authorized_keys
echo -ne "done!\n"

echo -ne "Get git repo up and running again ... "
sudo -u pfeerick git config --global user.email $GIT_EMAIL
sudo -u pfeerick git config --global user.name $GIT_USERNAME
sudo -u pfeerick mkdir -p /home/pfeerick/repos/rock64-scripts
sudo -u pfeerick git clone git@github.com:pfeerick/rock64-scripts.git /home/pfeerick/repos/rock64-scripts
echo -ne "done!\n"
