#!/bin/bash

echo "===> Adding keepalived apt repo"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7C33BDC6
cat >/etc/apt/sources.list.d/keepalived.list<<EOF
deb http://ppa.launchpad.net/keepalived/stable/ubuntu trusty main
EOF
apt-get update

echo "===> Installing keepalived"
apt-get install -y keepalived=1.2.13-0~276~ubuntu14.04.1

echo "===> Installing keepalived config files"
cp /home/ubuntu/scripts/$(hostname).conf /etc/keepalived/keepalived.conf
cp /home/ubuntu/scripts/master.sh /etc/keepalived/master.sh
rm /etc/init.d/keepalived
chmod +x /etc/keepalived/master.sh

echo "===> Installing nova client"
apt-get install -y python-novaclient

echo "===> Restarting keepalived"
service keepalived restart
