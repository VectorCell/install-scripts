#!/bin/bash

cd ~/Programs

wget -q https://download.sublimetext.com/sublimehq-pub.gpg
sudo apt-key add sublimehq-pub.gpg
sudo apt update && sudo apt install sublime-text
