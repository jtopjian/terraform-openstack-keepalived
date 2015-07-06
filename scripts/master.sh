#!/bin/bash

source /home/ubuntu/scripts/openrc

MY_UUID=$(grep MY_UUID /etc/keepalived/keepalived.conf | cut -d' ' -f3)
PEER_UUID=$(grep PEER_UUID /etc/keepalived/keepalived.conf | cut -d' ' -f3)
FLOATING_IP=$(grep FLOATING_IP /etc/keepalived/keepalived.conf | cut -d' ' -f3)

nova floating-ip-disassociate $PEER_UUID $FLOATING_IP
nova floating-ip-associate $MY_UUID $FLOATING_IP
