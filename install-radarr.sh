#!/bin/bash

cd ~/Programs

sudo apt install -y curl mediainfo
if [ "$?" != "0" ]; then
	1>&2 echo "ERROR: unable to install dependencies. Aborting."
	exit 1
fi

if [ ! -d /opt/Radarr ]; then
	curl -L -O $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
	tar -xvzf Radarr.develop.*.linux.tar.gz
	sudo mv Radarr /opt/
fi

sudo mkdir -p /opt/Radarr_data && sudo chown bismith:bismith /opt/Radarr_data

# SERVICEFILE=$(sudo find /etc/systemd/system/ -name "*sonarr*" | sed 's/sonarr/radarr/g')
# if [ -z "$SERVICEFILE" ]; then
# 	SERVICEFILE=/etc/systemd/system/radarr.service
# fi

SERVICEFILE=/etc/systemd/system/radarr.service
(
echo "[Unit]"
echo "Description=Radarr Daemon"
echo "After=network.target"
echo ""
echo "[Service]"
echo "User=bismith"
echo "Group=bismith"
echo "UMask=002"
echo ""
echo "Type=simple"
echo "ExecStart=/usr/bin/mono --debug /opt/Radarr/Radarr.exe -nobrowser -data=/opt/Radarr_data"
echo "TimeoutStopSec=20"
echo "KillMode=process"
echo "Restart=on-failure"
echo ""
echo "[Install]"
echo "WantedBy=multi-user.target"
) | sudo tee $SERVICEFILE

sudo systemctl daemon-reload \
	&& sudo systemctl enable radarr \
	&& sudo systemctl start radarr \
	&& echo "Radarr successfully installed. Running on port 7878."
