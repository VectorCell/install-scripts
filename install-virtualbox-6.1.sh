#!/bin/bash

CODENAME=$(lsb_release -c | awk '{print $2}')
if [ -z "$CODENAME" ]; then
	echo "ERROR: unable to get Debian or Ubuntu codename"
	exit 1
fi

echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $CODENAME contrib" \
	| sudo tee /etc/apt/sources.list.d/virtualbox.list

cd ~/Programs
wget https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc

sudo apt update && sudo apt install virtualbox-6.1
