#!/usr/bin/env bash

sudo apt update

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt --assume-yes install nodejs
sudo npm install -g pm2

cd /home/ubuntu/webserver
npm install

pm2 delete app > /dev/null
pm2 start app.js

sudo apt install stress-ng -y
