#!/bin/bash

set -e

if [ "$(id -u)" -ne "0" ]; then
        echo "This script requires root."
        exit 1
fi

#add my username
adduser pfeerick
usermod -aG sudo pfeerick

#update system
apt-get update && apt-get upgrade

#add network manager?
#apt-get install --no-install-recommends network-manager

#restore ssh key backup from server
wget -qO- 192.168.0.5/ssh-backup/rock64.tar.gz | tar -zvxf - -C /

#get git repo up and running again
sudo -u pfeerick bash -c "mkdir -p /home/pfeerick/repos/rock64-scripts && git clone git@github.com:pfeerick/rock64-scripts.git /home/pfeerick/repos/rock64-scripts"
