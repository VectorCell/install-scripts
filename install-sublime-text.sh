#!/bin/bash

cd ~/Programs

wget -q https://download.sublimetext.com/sublimehq-pub.gpg
sudo apt-key add sublimehq-pub.gpg
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublimetext.list
sudo apt update && sudo apt install -y sublime-text
