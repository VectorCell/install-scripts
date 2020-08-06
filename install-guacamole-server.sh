#!/bin/bash

# dependencies for guacamole server
echo -e "\nInstalling dependencies for Guacamole Server ..."
sudo apt -y install libcairo2-dev \
                    libjpeg-turbo8-dev \
                    libpng-dev \
                    libtool-bin \
                    libossp-uuid-dev \
                    libvncclient1 \
                    freerdp2-dev \
                    libssh2-1-dev \
                    pango1.0-tools \
                    libtelnet-dev \
                    libwebsockets-dev \
                    libavcodec-dev \
                    libavformat-dev \
                    libavutil-dev \
                    libswscale-dev \
                    libpulse-dev \
                    libssl-dev \
                    libvorbis-dev \
                    libwebp-dev \
                    libpango1.0-dev \
                    libvncserver-dev \
                    libvorbis-dev

cd ~/Programs

SERVER_URL="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.2.0/source/guacamole-server-1.2.0.tar.gz"
SERVER_TAR_FILENAME=$(echo "$SERVER_URL" | tr '/' ' ' | rev | awk '{print $1}' | rev)
SERVER_SRC_DIR=$(echo $SERVER_TAR_FILENAME | sed 's/\.tar\.gz$//')

if [ ! -d $SERVER_SRC_DIR ]; then
	wget -O $SERVER_TAR_FILENAME "$SERVER_URL"
	tar -xvf $SERVER_TAR_FILENAME
fi
cd $SERVER_SRC_DIR

./configure --with-init-dir=/etc/init.d
make clean
make
sudo make install
sudo ldconfig

sudo systemctl start guacd \
	&& sudo systemctl enable guacd \
	&& sudo systemctl status guacd
