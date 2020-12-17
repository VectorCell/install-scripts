#!/bin/bash

echo "deb [arch=amd64,armhf] http://repo.ombi.turd.me/stable/ jessie main" | sudo tee /etc/apt/sources.list.d/ombi.list
sudo apt update && sudo apt install -y ombi
