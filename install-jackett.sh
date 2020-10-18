#!/bin/bash

cd ~/Programs

if [ ! -f Jackett.Binaries.LinuxAMDx64.tar.gz ]; then
	wget https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz
fi

if [ ! -d /opt/Jackett ]; then
	tar -xvf Jackett.Binaries.LinuxAMDx64.tar.gz
	sudo mv Jackett /opt/
fi

cd /opt/Jackett \
	&& sudo ./install_service_systemd.sh \
	&& echo "Jackett successfully installed. Running on port 9117." \
	&& exit

1>&2 echo "ERROR: Problem installing Jackett."
exit 1
