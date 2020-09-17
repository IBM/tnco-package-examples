#!/bin/bash

# Invokes Create, Install, Configure, Start playbooks

##################################
### Mandatory properties:
APACHE_IP="10.21.28.127"

##################################
### Optional
# Apache jumphost
# IP of a host in the same subnet as the floating IP address used by openstack for the apache server
# JUMPHOST_IP="9.46.86.126"
# JUMPHOST_USER="root"
# JUMPHOST_PASSWORD="xxxxxxxx"

properties="{properties: {"
if [ -n "$JUMPHOST_IP" ] && [ -n "$JUMPHOST_USER" ] && [ -n "$JUMPHOST_PASSWORD" ]; then
  properties+="jumphost_ip: '$JUMPHOST_IP', jumphost_user: '$JUMPHOST_USER', jumphost_password: '$JUMPHOST_PASSWORD', "
fi
properties+="public_ip: '$APACHE_IP'}}"

### Stop
echo "Shutting down the apache server $APACHE_IP"
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$properties" ../ansible/scripts/Stop.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 