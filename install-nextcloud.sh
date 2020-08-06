#!/bin/bash


echo
echo "You are about to install NextCloud on $HOSTNAME"
while true; do
read -p "Are you sure you wish to continue? [y/n]:" yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo "not installing, exiting ..."; exit;;
		* ) echo "Please answer y or n.";;
	esac
done

# installs prerequisites

FLAGS_DIR=/home/$USER/.flags
if [ ! -d $FLAGS_DIR ]; then
	mkdir $FLAGS_DIR
fi

if [ ! -e $FLAGS_DIR/install-nextcloud-prerequisites ]; then

	sudo apt update
	sudo apt -y install apache2 mariadb-server libapache2-mod-php7.4
	sudo apt -y install php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl
	sudo apt -y install php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip

	echo
	echo
	echo "Starting MySQL command line mode."
	echo "Press the enter key when prompted for a password."
	echo "Once the prompt appears, enter the following commands,"
	echo "replacing username and password with appropriate values:"
	echo
	echo "CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';"
	echo "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	echo "GRANT ALL PRIVILEGES ON nextcloud.* TO 'username'@'localhost';"
	echo "FLUSH PRIVILEGES;"
	echo "quit;"
	echo
	sudo mysql -uroot -p

	touch $FLAGS_DIR/install-nextcloud-prerequisites
fi


# downloads NextCloud

NEXTCLOUD_URL=https://download.nextcloud.com/server/releases/nextcloud-19.0.1.tar.bz2
NEXTCLOUD_ARCHIVE=/home/$USER/Programs/$(echo $NEXCLOUD_URL | rev | tr '/' ' ' | awk '{print $1}' | rev)
echo "checking for $NEXTCLOUD_ARCHIVE"
if [ ! -e $NEXTCLOUD_ARCHIVE ]; then
	wget -O $NEXTCLOUD_ARCHIVE $NEXTCLOUD_URL
fi


echo "stopping here"
exit 0

APACHE_DOCUMENT_ROOT=$(grep -i 'DocumentRoot' /etc/apache2/sites-available/000-default.conf | awk '{print $2}')

echo "extracting $NEXTCLOUD_ARCHIVE to $APACHE_DOCUMENT_ROOT"
sudo tar -xvf $NEXTCLOUD_ARCHIVE -C $APACHE_DOCUMENT_ROOT
echo "extracted $NEXTCLOUD_ARCHIVE to $APACHE_DOCUMENT_ROOT"
