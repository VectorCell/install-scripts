#!/bin/bash

ATTEMPTS=0
while [ -z "$(which ethtool)" ]; do
	if [ $ATTEMPTS == 0 ]; then
		echo "WARNING: Unable to find ethtool. Attempting to install ..." 1>&2
		sudo apt update
		sudo apt install -y ethtool
		ATTEMPTS=1
	elif [ $ATTEMPTS == 1 ]; then
		echo "ERROR: Unable to install ethtool. Aborting!" 1>&2
		exit 1
	fi
done

INTERFACE=$(ip r | grep ^default | awk '{print $5}')
if [ -z "$INTERFACE" ]; then
	echo "ERROR: unable to find default network interface" 1>&2
	echo "Do you not have a default route? Here is the output of \"ip r\":" 1>&2
	ip r 1>&2
	exit 1
fi

while true; do
read -p "Enable WOL on interface $INTERFACE? [y/n]:" yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo "not installing, exiting ..."; exit;;
		* ) echo "Please answer yes or no.";;
	esac
done

if [ -z "$(sudo ethtool $INTERFACE | grep Wake-on | grep Supports | awk '{print $3}' | grep g)" ]; then
	echo "ERROR: $INTERFACE does not appear to support Wake-on-LAN" 1>&2
	exit 1
fi

if [ -n "$(sudo ethtool $INTERFACE | grep Wake-on | grep -v Supports | awk '{print $2}' | grep g)" ]; then
	echo "Wake-on-LAN appears to already be enabled on $INTERFACE" 1>&2
	sudo ethtool $INTERFACE 1>&2
	exit 0
fi

# enables Wake-on-LAN
sudo ethtool -s $INTERFACE wol g

# makes the change stick by creating a service
echo "creating service with configuration:"
(
	echo "[Unit]"
	echo "Description=Configure Wake On LAN"
	echo ""
	echo "[Service]"
	echo "Type=oneshot"
	echo "ExecStart=$(which ethtool) -s $INTERFACE wol g"
	echo ""
	echo "[Install]"
	echo "WantedBy=basic.target"
) | sudo tee /etc/systemd/system/wol.service
sudo systemctl daemon-reload \
	&& sudo systemctl enable wol.service \
	&& sudo systemctl start wol.service \
	&& echo "service created successfully"
