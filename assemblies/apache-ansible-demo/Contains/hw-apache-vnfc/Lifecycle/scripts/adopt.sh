#!/bin/bash

# Invokes Create, Install, Configure, Start playbooks

##################################
### Mandatory properties:
# Deployment location:
OS_URL="http://9.46.89.80/"
OS_AUTH_PASSWORD="xxxxxxxx"
OS_AUTH_PROJECT_NAME="elisabetta"
OS_AUTH_USERNAME="elisabetta"
# Stack
STACK_ID="eeb6a3ba-e37e-45c3-b2be-98a9b0d70384"

##################################
### Optional
# OS_AUTH_API="identity/v3"
# OS_AUTH_PROJECT_DOMAIN_NAME="default"
# OS_AUTH_USER_DOMAIN_NAME="default"
#
# Ansible hosts:
# REMOTE_HOST="9.46.89.80"
# REMOTE_USER="root"
# REMOTE_PASSWORD="xxxxxxxx"
# Apache jumphost:
# IP of a host in the same subnet as the floating IP address used by openstack for the apache server
# JUMPHOST_IP="9.46.86.126"
# JUMPHOST_USER="root"
# JUMPHOST_PASSWORD="xxxxxxxx"

if [ -z "$OS_AUTH_API" ]; then
  OS_AUTH_API="identity/v3"
fi

if [ -z "$OS_AUTH_PROJECT_DOMAIN_NAME" ]; then
  OS_AUTH_PROJECT_DOMAIN_NAME="default"
fi
  
if [ -z "$OS_AUTH_USER_DOMAIN_NAME" ]; then
  OS_AUTH_USER_DOMAIN_NAME="default"
fi

deployment_location="{deployment_location: {properties: {os_api_url: '$OS_URL', os_auth_api: '$OS_AUTH_API', os_auth_password: '$OS_AUTH_PASSWORD', os_auth_project_name: '$OS_AUTH_PROJECT_NAME', os_auth_project_domain_name: '$OS_AUTH_PROJECT_DOMAIN_NAME', os_auth_user_domain_name: '$OS_AUTH_USER_DOMAIN_NAME', os_auth_username: '$OS_AUTH_USERNAME'}}}"

properties="{properties: {"
if [ -n "$JUMPHOST_IP" ] && [ -n "$JUMPHOST_USER" ] && [ -n "$JUMPHOST_PASSWORD" ]; then
  properties+="jumphost_ip: '$JUMPHOST_IP', jumphost_user: '$JUMPHOST_USER', jumphost_password: '$JUMPHOST_PASSWORD'"
fi
if [ -n "$REMOTE_HOST" ] && [ -n "$REMOTE_USER" ] && [ -n "$REMOTE_PASSWORD" ]; then
  if [ ${#properties} -gt 14 ]; then 
    properties+=", "
  fi
  properties+="remote_host: '$REMOTE_HOST', remote_user: '$REMOTE_USER', remote_pass: '$REMOTE_PASSWORD'" 
fi
properties+="}}"

associated_topology="{associated_topology: {stack: {id: '$STACK_ID', type: 'Openstack'}}}"

### Adopt
echo "Adopting the stack $STACK_ID.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$deployment_location" -e "$associated_topology" -e "$properties" ../ansible/scripts/Adopt.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 
