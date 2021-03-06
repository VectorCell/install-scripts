#!/bin/bash

sudo apt update && sudo apt install -y cockpit
if [ "$?" != "0" ]; then
	1>&2 echo "ERROR: unable to install cockpit"
	exit 1
fi

if [ -n "$(command -v samba)" ]; then
	sudo sh -c 'echo "$(logname) ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cockpit-smb'
	wget -O - https://raw.githubusercontent.com/enira/cockpit-smb-plugin/master/install.sh | sudo bash
else
	echo "Samba not found. Skipping Samba plugin installation."
fi

(
echo "[WebService]"
echo "Origins = https://vpn.bismith.net wss://vpn.bismith.net"
echo "ProtocolHeader = X-Forwarded-Proto"
echo "UrlRoot=/$HOSTNAME"
) | sudo tee /etc/cockpit/cockpit.conf

sudo systemctl restart cockpit && echo "DONE"
