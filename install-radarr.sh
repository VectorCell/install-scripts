#!/bin/bash

cd ~/Programs

sudo apt update && sudo apt install -y curl mediainfo
if [ "$?" != "0" ]; then
	1>&2 echo "ERROR: unable to install dependencies. Aborting."
	exit 1
fi

curl -L -O $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Radarr.develop.*.linux.tar.gz
mv Radarr /opt
