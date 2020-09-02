#!/bin/bash

echo
echo "installing kodi ..."
sudo apt update && sudo apt install -y kodi || (echo "ERROR: unable to install kodi from repo" 1>&2 ; exit 1)
echo "DONE"

echo
echo "creating service ..."
(
	echo "[Unit]"
	echo "Description = Kodi Media Center"
	echo "After = remote-fs.target network-online.target"
	echo "Wants = network-online.target"
	echo ""
	echo "[Service]"
	echo "User = $USER"
	echo "Group = $USER"
	echo "Type = simple"
	echo "ExecStart = /usr/bin/kodi-standalone"
	echo "Restart = on-abort"
	echo "RestartSec = 5"
	echo ""
	echo "[Install]"
	echo "WantedBy = multi-user.target"
) | sudo tee /lib/systemd/system/kodi.service
sudo systemctl enable kodi.service
echo "DONE"

echo
echo "Kodi is now installed and configured to start at boot using user $USER"
