#!/bin/bash

STARTUP_SCRIPT=/home/$USER/Programs/startup.sh
SERVICE_CONFIG=/etc/systemd/system/startup.service

if [ -e "$SERVICE_CONFIG" ]; then
	echo "ERROR: service config already exists at $SERVICE_CONFIG" 1>&2
	exit 1
fi

if [ ! -e $STARTUP_SCRIPT ]; then
	echo -e "#!/bin/bash\n" > $STARTUP_SCRIPT
	chmod +x $STARTUP_SCRIPT
	echo "Created default startup script at $STARTUP_SCRIPT"
else
	echo "Using startup script found at $STARTUP_SCRIPT"
fi

(
echo "[Unit]"
echo "After=network.service"
echo ""
echo "[Service]"
echo "ExecStart=su $USER -c $STARTUP_SCRIPT"
echo ""
echo "[Install]"
echo "WantedBy=default.target"
) | sudo tee $SERVICE_CONFIG
sudo chmod 744 $SERVICE_CONFIG

sudo systemctl daemon-reload
sudo systemctl enable startup.service && echo "startup.service successfully enabled!"
