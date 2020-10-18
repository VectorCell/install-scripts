#!/bin/bash

RELEASE_CODENAME=$(lsb_release -a | grep ^Codename | awk '{print $2}')

# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8
# echo "deb https://apt.sonarr.tv/ubuntu $RELEASE_CODENAME main" | sudo tee /etc/apt/sources.list.d/sonarr.list

if [ "$RELEASE_CODENAME" != "focal" ] && [ "$RELEASE_CODENAME" != "bionic" ] && [ "$RELEASE_CODENAME" != "xenial" ]; then
	1>&2 echo "ERROR: unable to determine release codename, or unsupported codename: $RELEASE_CODENAME"
	exit 1
fi

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8
echo "deb https://apt.sonarr.tv/ubuntu $RELEASE_CODENAME main" | sudo tee /etc/apt/sources.list.d/sonarr.list

sudo apt install -y sonarr && echo "Sonarr installed successfully! Listening on port 8989."
