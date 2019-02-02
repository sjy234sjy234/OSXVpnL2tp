#!/bin/bash

#set -e


vpnname="$1"
username="$2"
password="$3"
serverip="$4"

./VPNManager "$vpnname" "$username" "$password" "$serverip"

cp ./options /etc/ppp/options
