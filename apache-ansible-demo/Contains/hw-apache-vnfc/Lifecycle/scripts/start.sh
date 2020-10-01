#!/bin/bash

# Invokes Create, Install, Configure, Start playbooks

##################################
### Mandatory properties:
# Apache jumphost
# IP of a host in the same subnet as the floating IP address used by openstack for the apache server
APACHE_IP="10.21.28.127"

#####################################
### Additional properties:
###
# Apache jumphost.
# IP of a host in the same subnet as the floating IP address used by openstack for the apache server
# JUMPHOST_IP="10.0.0.3"
# JUMPHOST_USER="jumphost-user"
# JUMPHOST_PASSWORD="password"

properties="{properties: {"
if [ -n "$JUMPHOST_IP" ] && [ -n "$JUMPHOST_USER" ] && [ -n "$JUMPHOST_PASSWORD" ]; then
  properties+="jumphost_ip: '$JUMPHOST_IP', jumphost_user: '$JUMPHOST_USER', jumphost_password: '$JUMPHOST_PASSWORD', "
fi
properties+="public_ip: '$APACHE_IP'}}"

### Start
echo "Starting the apache server $APACHE_IP.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$properties" ../ansible/scripts/Start.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 
