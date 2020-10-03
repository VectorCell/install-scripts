#!/bin/bash

sudo apt update \
	&& sudo apt install apt-transport-https \
	&& sudo apt-add-repository universe \
	&& sudo apt update \
	&& sudo apt install -y gnupg2 \
	&& curl https://download.jitsi.org/jitsi-key.gpg.key \
		| sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg' \
	&& echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' \
		| sudo tee /etc/apt/sources.list.d/jitsi-stable.list \
	&& echo apt update \
	&& sudo apt install -y jitsi-meet \
	&& echo "Jitsi Meet installed successfully."

if [ $? -ne 0 ]; then
	>&2 echo "ERROR: unable to install required packages using apt"
	exit 1
fi
