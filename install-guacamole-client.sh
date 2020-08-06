#!/bin/bash

# dependencies for guacamole client
echo -e "\nInstalling dependencides for Guacamole Client ..."
# sudo apt install maven openjdk-11-jdk # for building
# sudo apt -y install openjdk-11-jdk # for manual tomcat installation
sudo apt -y install tomcat9 tomcat9-admin

cd ~/Programs

CLIENT_URL="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.2.0/binary/guacamole-1.2.0.war"
CLIENT_WAR=$(echo "$CLIENT_URL" | tr '/' ' ' | rev | awk '{print $1}' | rev)
if [ ! -f $CLIENT_WAR ]; then
	wget -O $CLIENT_WAR "$CLIENT_URL"
fi

TOMCAT_DIR=$(find /var/lib -type d -name "*tomcat*" 2> /dev/null | sort | head -n 1)
TOMCAT_WEBAPPS=$TOMCAT_DIR/webapps
echo "TOMCAT_WEBAPPS: $TOMCAT_WEBAPPS"
if [ ! -f $TOMCAT_WEBAPPS/guacamole.war ]; then
	
	sudo cp $CLIENT_WAR $TOMCAT_WEBAPPS/guacamole.war
	sudo chown tomcat:tomcat $TOMCAT_WEBAPPS/guacamole.war
fi
ls -lh $TOMCAT_WEBAPPS/guacamole.war

GUACAMOLE_HOME=/etc/guacamole

sudo mkdir $GUACAMOLE_HOME
sudo mkdir $GUACAMOLE_HOME/{extensions,lib}
CONFIG_LINE="GUACAMOLE_HOME=$GUACAMOLE_HOME"
if [ -n "$(cat /etc/default/tomcat9 | grep $CONFIG_LINE)" ]; then
	echo "GUACAMOLE_HOME=$GUACAMOLE_HOME" | sudo tee -a /etc/default/tomcat9
fi

(
	echo "guacd-hostname: localhost"
	echo "guacd-port:     4822"
	echo "user-mapping:   $GUACAMOLE_HOME/user-mapping.xml"
	echo "auth-provider:  net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider"
) | sudo tee $GUACAMOLE_HOME/guacamole.properties
sudo ln -s $GUACAMOLE_HOME /usr/share/tomcat9/.guacamole

(
	echo '<user-mapping>'
	echo '    <!-- Per-user authentication and config information -->'
	echo '    <!-- A user using md5 to hash the password'
	echo '         bismith user and its md5 hashed password below is used to '
	echo '             login to Guacamole Web UI-->'
	echo '    <authorize '
	echo '            username="bismith"'
	echo '            password="03bcfc6ace4cd36cfb1d7ac4ed4eeb86"'
	echo '            encoding="md5">'
	echo '        <!-- First authorized Remote connection -->'
	echo '        <connection name="vps.bismith.net">'
	echo '            <protocol>ssh</protocol>'
	echo '            <param name="hostname">vps.bismith.net</param>'
	echo '            <param name="port">22</param>'
	echo '        </connection>'
	echo '        <!-- Second authorized remote connection -->'
	echo '        <connection name="LBBTerm">'
	echo '            <protocol>rdp</protocol>'
	echo '            <param name="hostname">lbbterm.lbb.state.tx.us</param>'
	echo '            <param name="port">3389</param>'
	echo '            <param name="username">bsmith</param>'
	echo '            <param name="ignore-cert">true</param>'
	echo '        </connection>'
	echo '    </authorize>'
	echo '</user-mapping>'
) | sudo tee $GUACAMOLE_HOME/user-mapping.xml

sudo systemctl restart tomcat9 guacd

# we can skip the rest, since we are installing tomcat via apt
echo "You should now be able to access guacamole at http://10.0.1.4:8080/guacamole"
exit 0

# if attempting to build from source
# CLIENT_URL="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.2.0/source/guacamole-client-1.2.0.tar.gz"
# CLIENT_TAR_FILENAME=$(echo "$CLIENT_URL" | tr '/' ' ' | rev | awk '{print $1}' | rev)
# CLIENT_SRC_DIR=$(echo $CLIENT_TAR_FILENAME | sed 's/\.tar\.gz$//')
# if [ ! -d $CLIENT_SRC_DIR ]; then
# 	wget -O $CLIENT_TAR_FILENAME "$CLIENT_URL"
# 	tar -xvf $CLIENT_TAR_FILENAME
# fi
# cd $CLIENT_SRC_DIR
# export JAVA_HOME=$(realpath $(which java) | sed 's/\/bin\/java$//')
# mvn package

TOMCAT_URL="http://www.trieuvan.com/apache/tomcat/tomcat-9/v9.0.37/bin/apache-tomcat-9.0.37.tar.gz"
TOMCAT_TAR=$(echo "$TOMCAT_URL" | tr '/' ' ' | rev | awk '{print $1}' | rev)
if [ ! -f $TOMCAT_TAR ]; then
	wget -O $TOMCAT_TAR "$TOMCAT_URL"
fi
TOMCAT_DIR=$(echo "$TOMCAT_TAR" | sed 's/\.tar\.gz$//')

TOMCAT_HOME=/opt/tomcat

# from https://www.cloudbooklet.com/install-apache-tomcat-on-ubuntu-20-04-google-cloud/
# if [ -n "$(id -u tomcat 2> /dev/null)" ]; then
# 	sudo mkdir $TOMCAT_HOME
# 	sudo groupadd tomcat
# 	sudo useradd -s /bin/false -g tomcat -d $TOMCAT_HOME tomcat
# 	sudo tar -xvf $TOMCAT_TAR -C $TOMCAT_HOME
# 	sudo chgrp -R tomcat $TOMCAT_HOME
# 	sudo chmod -R g+r conf
# 	sudo chmod g+x conf
# 	sudo mkdir -p $TOMCAT_HOME/webapps $TOMCAT/work $TOMCAT/temp $TOMCAT/logs
# 	sudo chown -R tomcat $TOMCAT_HOME/webapps/ $TOMCAT_HOME/work/ $TOMCAT_HOME/temp/ $TOMCAT_HOME/logs/
# fi

# from https://linuxize.com/post/how-to-install-tomcat-9-on-ubuntu-20-04/
sudo mkdir -p $TOMCAT_HOME
sudo rm -rf $TOMCAT_HOME/*
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
sudo tar -xvf $TOMCAT_TAR -C $TOMCAT_HOME
sudo mv $TOMCAT_HOME/$TOMCAT_DIR/* $TOMCAT_HOME/
sudo rmdir $TOMCAT_HOME/$TOMCAT_DIR
sudo find $TOMCAT_HOME | sort
sudo chown -R tomcat:tomcat $TOMCAT_HOME
# sudo chmod +x $TOMCAT_HOME/bin/*.sh

JAVA_HOME=$(realpath $(which java) | sed 's/\/bin\/java$//')
TEMPFILE=$(mktemp)
(
	echo "[Unit]"
	echo "Description=Apache Tomcat Web Application Container"
	echo "After=network.target"
	echo ""
	echo "[Service]"
	echo "Type=forking"
	echo ""
	echo "Environment=JAVA_HOME=$JAVA_HOME"
	echo "Environment=CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid"
	echo "Environment=CATALINA_HOME=$TOMCAT_HOME/bin"
	echo "Environment=CATALINA_BASE=$TOMCAT_HOME"
	echo "Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'"
	echo "Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'"
	echo ""
	echo "ExecStart=$TOMCAT_HOME/bin/startup.sh"
	echo "ExecStop=$TOMCAT_HOME/bin/shutdown.sh"
	echo ""
	echo "User=tomcat"
	echo "Group=tomcat"
	echo "UMask=0007"
	echo "RestartSec=10"
	echo "Restart=always"
	echo ""
	echo "[Install]"
	echo "WantedBy=multi-user.target"
) > $TEMPFILE
sudo cp $TEMPFILE /etc/systemd/system/tomcat.service
rm -f $TEMPFILE

sudo systemctl daemon-reload \
	&& sudo systemctl start tomcat \
	&& sudo systemctl enable tomcat \
	&& echo "service created and started:" \
	&& sudo systemctl status tomcat
