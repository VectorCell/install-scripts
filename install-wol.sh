#!/bin/bash

ATTEMPTS=0
while [ -z "$(which ethtool)" ]; do
	if [ $ATTEMPTS == 0 ]; then
		echo "WARNING: Unable to find ethtool. Attempting to install ..."
		sudo apt update
		sudo apt install -y ethtool
		ATTEMPTS=1
	elif [ $ATTEMPTS == 1 ]; then
		echo "ERROR: Unable to install ethtool. Aborting!"
		exit 1
	fi
done

INTERFACE=$(ip r | grep ^default | awk '{print $5}')
if [ -z "$INTERFACE" ]; then
	echo "ERROR: unable to find default network interface"
	echo "Do you not have a default route? Here is the output of \"ip r\":"
	ip r
	exit 1
fi

echo "Enable WOL on interface $INTERFACE?"
