#!/bin/bash

# Invokes Create, Install, Configure, Start playbooks

###############################################
###
### Properties for the OpenStack environment.
### Corresponds to the deployment location properties
###
OS_URL="http://openstack-server/"
OS_AUTH_PROJECT_NAME="openstack-project"
OS_AUTH_USERNAME="openstack-user"
OS_AUTH_PASSWORD="password"
# OS_AUTH_API="identity/v3"
# OS_AUTH_PROJECT_DOMAIN_NAME="default"
# OS_AUTH_USER_DOMAIN_NAME="default"
# Full path to the CA certificate
# OS_CACERT_FILE="/root/certs/ca.pem"
# Full path to the client certificate
# OS_CLIENT_CERT_FILE="/root/certs/cert.pem"
# Full path to the client key
# OS_KEY_FILE="/root/keys/key"

### Stack ID to adopt:
STACK_ID="eeb6a3ba-e37e-45c3-b2be-98a9b0d70384"

#####################################
### Additional properties:
###
# Ansible host. 
# If set, the playbook is run remotely on the specified host.
# REMOTE_HOST="10.0.0.2"
# REMOTE_USER="remote-user"
# REMOTE_PASSWORD="password"
# Apache jumphost.
# IP of a host in the same subnet as the floating IP address used by openstack for the apache server
# JUMPHOST_IP="10.0.0.3"
# JUMPHOST_USER="jumphost-user"
# JUMPHOST_PASSWORD="password"

if [ -z "$OS_AUTH_API" ]; then
  OS_AUTH_API="identity/v3"
fi

if [ -z "$OS_AUTH_PROJECT_DOMAIN_NAME" ]; then
  OS_AUTH_PROJECT_DOMAIN_NAME="default"
fi
  
if [ -z "$OS_AUTH_USER_DOMAIN_NAME" ]; then
  OS_AUTH_USER_DOMAIN_NAME="default"
fi

if [ -z "$OS_CLIENT_CERT_FILE" ]; then
  OS_CLIENT_CERT=""
else
  OS_CLIENT_CERT="$OS_CLIENT_CERT_FILE" 
fi

if [ -z "$OS_KEY_FILE" ]; then
  OS_KEY=""
else
  OS_KEY="$OS_KEY_FILE" 
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
if [ ${#properties} -gt 14 ]; then
  properties+=", "
fi
properties+="os_cacert: '$OS_CACERT',  cert_file: '$OS_CLIENT_CERT', key_file: '$OS_KEY'}}"

associated_topology="{associated_topology: {stack: {id: '$STACK_ID', type: 'Openstack'}}}"

### Adopt
echo "Adopting the stack $STACK_ID.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$deployment_location" -e "$associated_topology" -e "$properties" ../ansible/scripts/Adopt.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 
