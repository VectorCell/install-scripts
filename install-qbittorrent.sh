#!/bin/bash

sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
sudo apt update
sudo apt install -y qbittorrent-nox

# run qBittorrent at startup
(
	echo "[Unit]"
	echo "Description=qBittorrent Command Line Client"
	echo "After=network.target"
	echo ""
	echo "[Service]"
	echo "# do not change to \"simple\""
	echo "Type=forking"
	echo "User=bismith"
	echo "Group=bismith"
	echo "UMask=007"
	echo "ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080"
	echo "Restart=on-failure"
	echo ""
	echo "[Install]"
	echo "WantedBy=multi-user.target"
) | sudo tee /etc/systemd/system/qbittorrent-nox.service

sudo systemctl daemon-reload
sudo systemctl enable qbittorrent-nox.service
sudo systemctl start qbittorrent-nox.service
