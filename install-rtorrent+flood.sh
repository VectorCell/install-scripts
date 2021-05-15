#!/bin/bash

# THIS SCRIPT DOESN'T WORK YET

# install rtorrent, Node.JS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt update
sudo apt install -y curl git rtorrent nodejs

# .rtorrent.rc config file
(
	echo "# Where rTorrent saves the downloaded files"
	echo "directory = /mnt/downloads/rtorrent/downloads"
	echo ""
	echo "# Where rTorrent saves the session"
	echo "session = /mnt/downloads/rtorrent/.session"
	echo ""
	echo "# Which ports rTorrent can use (Make sure to open them in your router)"
	echo "port_range = 50000-59999"
	echo "port_random = yes"
	echo ""
	echo "# Check the hash after the end of the download"
	echo "check_hash = yes"
	echo ""
	echo "# Enable DHT (for torrents without trackers)"
	echo "dht = auto"
	echo "dht_port = 6881"
	echo "peer_exchange = yes"
	echo ""
	echo "# Authorize UDP trackers"
	echo "use_udp_trackers = yes"
	echo ""
	echo "# Enable encryption when possible"
	echo "encryption = allow_incoming,try_outgoing,enable_retry"
	echo ""
	echo "# SCGI port, used to communicate with Flood"
	echo "scgi_port = 127.0.0.1:5000"
) > ~/.rtorrent.rc

# run rtorrent at boot
(
	echo "[Unit]"
	echo "Description=rTorrent"
	echo "After=network.target"
	echo ""
	echo "[Service]"
	echo "Type=forking"
	echo "KillMode=none"
	echo "User=bismith"
	echo "WorkingDirectory=%h"
	echo "ExecStartPre=/bin/bash -c \"if test -e %h/.session/rtorrent.lock && test -z 'pidof rtorrent'; then rm -f %h/.session/rtorrent.lock; fi\""
	echo "ExecStart=/usr/bin/screen -dmfa -S rtorrent /usr/bin/rtorrent"
	echo "ExecStop=/bin/bash -c \"test 'pidof rtorrent' && killall -w -s 2 /usr/bin/rtorrent\""
	echo "Restart=on-failure"
	echo ""
	echo "[Install]"
	echo "WantedBy=multi-user.target"
) | sudo tee /etc/systemd/system/rtorrent.service
sudo systemctl enable rtorrent.service
sudo systemctl start rtorrent.service

# install flood
cd ~
git clone https://github.com/jfurrow/flood.git
cd flood
cp config.template.js config.js
npm install
npm run build

# run flood at boot
(
	echo "[Service]"
	echo "WorkingDirectory=/home/$USER/flood"
	echo "ExecStart=/usr/bin/npm start"
	echo "Restart=always"
	echo "StandardOutput=syslog"
	echo "StandardError=syslog"
	echo "SyslogIdentifier=notell"
	echo "User=$USER"
	echo "Group=$USER"
	echo "Environment=NODE_ENV=production"
	echo ""
	echo "[Install]"
	echo "WantedBy=multi-user.target"
) | sudo tee /etc/systemd/system/flood.service
sudo systemctl enable flood.service
sudo systemctl start flood.service
