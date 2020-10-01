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

# ID of the stack to delete:
STACK_ID="d75c2b8f-3ebd-4c8b-b7f1-6a018ace2b75"

#####################################
### Additional properties:
###
# Ansible host. 
# If set, the playbook is run remotely on the specified host.
# REMOTE_HOST="10.0.0.2"
# REMOTE_USER="remote-user"
# REMOTE_PASSWORD="password"

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
if [ -n "$REMOTE_HOST" ] && [ -n "$REMOTE_USER" ] && [ -n "$REMOTE_PASSWORD" ]; then
  remote_properties="{properties: {remote_host: '$REMOTE_HOST', remote_user: '$REMOTE_USER', remote_pass: '$REMOTE_PASSWORD'}}" 
fi
associated_topology="{associated_topology: {stack: {id: '$STACK_ID', type: 'Openstack'}}}"

### Delete
echo "Deleting the stack $STACK_ID.."
result="$( ansible-playbook  -i ../ansible/config/inventory  -e "$deployment_location" -e "$associated_topology" -e "$remote_properties" ../ansible/scripts/Delete.yaml )"

ret="$?"
echo "$result"
if [ $ret -ne 0 ]; then
  exit 1
fi 
