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

### HEAT template input parameters:
# PUBLIC_NETWORK="public"

### Configuration parameters for the apache server:
# APACHE_SITE="hw"
# APACHE_SITE_ADMIN_EMAIL="host@localhost"
# APACHE_SITE_PORT="80"
# APACHE_SITE_GREETING_RECEIVER="world"

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

if [ -z "$OS_CACERT_FILE" ]; then
  OS_CACERT=""
else
  OS_CACERT="$OS_CACERT_FILE" 
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

if [ -z "$PUBLIC_NETWORK" ]; then
  PUBLIC_NETWORK="public"
fi

if [ -z "$APACHE_SITE" ]; then
  APACHE_SITE="hw"
fi

if [ -z "$APACHE_SITE_ADMIN_EMAIL" ]; then
  APACHE_SITE_ADMIN_EMAIL="host@localhost"
fi

if [ -z "$APACHE_SITE_PORT" ]; then
  APACHE_SITE_PORT="80"
fi

if [ -z "$APACHE_SITE_GREETING_RECEIVER" ]; then
  APACHE_SITE_GREETING_RECEIVER="world"
fi


### Create
deployment_location="{deployment_location: {properties: {os_api_url: '$OS_URL', os_auth_api: '$OS_AUTH_API', os_auth_password: '$OS_AUTH_PASSWORD', os_auth_project_name: '$OS_AUTH_PROJECT_NAME', os_auth_project_domain_name: '$OS_AUTH_PROJECT_DOMAIN_NAME', os_auth_user_domain_name: '$OS_AUTH_USER_DOMAIN_NAME', os_auth_username: '$OS_AUTH_USERNAME'}}}"
properties="{properties: {"
if [ -n "$REMOTE_HOST" ] && [ -n "$REMOTE_USER" ] && [ -n "$REMOTE_PASSWORD" ]; then
  properties+="remote_host: '$REMOTE_HOST', remote_user: '$REMOTE_USER', remote_pass: '$REMOTE_PASSWORD', " 
fi
properties+="public_network: '$PUBLIC_NETWORK', cacert_file: '$OS_CACERT', cert_file: '$OS_CLIENT_CERT', key_file: '$OS_KEY'}}"

echo "Creating the stack.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$deployment_location" -e "$properties" ../ansible/scripts/Create.yaml )"

ret="$?"
echo "$result"
if [ "$ret" -ne 0 ]; then
  exit 1
fi 

### Set properties
# result="$( echo "$result" | grep -A1 "TASK \[set public ip\]" | grep "ok:" )"
result=${result//\'/}
apache_ip="$( echo "$result"  | grep -A2 "TASK \[set public ip\]" | grep "ok:" | awk -F'[ {},]' '{for(i=1; i<=NF; i++) if($i=="output_value:") print $(i+1) }' )"
properties="{properties: {"
if [ -n "$JUMPHOST_IP" ] && [ -n "$JUMPHOST_USER" ] && [ -n "$JUMPHOST_PASSWORD" ]; then
  properties+="jumphost_ip: '$JUMPHOST_IP', jumphost_user: '$JUMPHOST_USER', jumphost_password: '$JUMPHOST_PASSWORD', "
fi
properties+="public_ip: '$apache_ip', site_name: '$APACHE_SITE', site_port: '$APACHE_SITE_PORT', site_admin_email: \
'$APACHE_SITE_ADMIN_EMAIL', greeting_receiver: '$APACHE_SITE_GREETING_RECEIVER'}}"

### Install
echo "Installing the apache server $apache_ip.."
sleep 500
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$properties" ../ansible/scripts/Install.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 

### Configure
echo "Configuring the apache server $apache_ip.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$properties" ../ansible/scripts/Configure.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 

### Start
echo "Starting the apache server $apache_ip.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$properties" ../ansible/scripts/Start.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi
