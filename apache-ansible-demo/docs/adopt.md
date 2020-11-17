This example describes adopting a stack by using the apache-ansible-demo resource package, the [Ansible Lifecycle Driver](https://github.com/IBM/ansible-lifecycle-driver) and IBM® Telco Network Cloud Manager - Orchestration.

### Before you begin
This example describes the steps of an Adopt scenario that uses the apache-ansible-demo resource package, the Ansible Lifecycle Driver and IBM Telco Network Cloud Manager - Orchestration.

The apache-ansible-demo contains descriptors for the creation and management of an Apache server and the underlying infrastructure on Red Hat OpenStack. The lifecycle of the resource that is defined in the package includes an Adopt transition that is handled by the Ansible Lifecycle Driver through Ansible Playbooks.

To follow this example, you require the following prerequisites:

* [Prerequisites to run the resource package](./prerequisites.md)
* An installed instance of IBM Telco Network Cloud Manager - Orchestration.
* The Ansible Lifecycle Driver on-boarded.
* The Deployment Location created that describes the OpenStack environment and that specifies the Openstack project domain name in the parameter _os_auth_project_domain_name_.
* The system on which the example's steps are run has ansible, openstacksdk, sshpass, and zip installed.
* The system on which the example's steps are run and the instance of IBM Telco Network Cloud Manager - Orchestration has connectivity to the floating IP addresses configured in OpenStack.
* The system on which the example's steps are run has the environment variable ANSIBLE_HOST_KEY_CHECKING set to False and any host entries related to the floating IP addresses configured in OpenStack are removed from the known_hosts file

### Procedure

1. Download the apache-ansible-demo resource package:  
```
git clone https://github.com/IBM/tnco-package-examples
```

2. Create an OpenStack stack that can be adopted by an assembly:  
```
cd tnco-package-examples/apache-ansible-demo/Contains/hw-apache-vnfc/Lifecycle/scripts/
```

Edit the script file create.sh and customize the uncommented variables in the script:
```
OS_URL=<openstack-server-url>
OS_AUTH_PROJECT_NAME=<openstack-project>
OS_AUTH_USERNAME=<openstack-username>
OS_AUTH_PASSWORD=<password>
```

Where:
   * OS_URL is the URL to the OpenStack server.
   * OS_AUTH_PROJECTNAME is the name of the OpenStack project that is associated with the OpenStack user.
   * OS_AUTH_USERNAME and OS_AUTH_PASSWORD are the username and password of the OpenStack user.

Depending on the OpenStack environment, you might need to set other variables in the script that are commented out. For example, if the OpenStack environment is set up to support Transport Layer Security (TLS), you might need to set the variable OS_CACERT_FILE to point to a file that stores the OpenStack CA certificates.

Run the create.sh script:
```
./create.sh
```
  
The script runs the ansible playbooks contained in the resource package to create an OpenStack stack with infrastructure resources to host an Apache server. The Apache server is then configured and started.
  
3. Verify that the OpenStack stack is created.  
   1. Log in to the OpenStack dashboard with your OpenStack username and password.  
   2. Click the project menu and select the OpenStack project that you specified in the create.sh script.  
   3. From the Orchestration menu, select Stacks. You see a new stack with a name that starts with apache_ansible.  
  
4. Save the stack ID in a variable to use as an input parameter for the Adopt REST API.  
   1. In the OpenStack dashboard, click the created stack, and then click Overview.  
   2. Copy the stack ID, and use it to set the STACK_ID environment variable:  
   ```
   export STACK_ID=<stack_id>
   ```

5. Verify that the Apache server is up and running:  
   1. From the stack Overview, collect the value of the public_ip parameter. The public_ip parameter is the IP address that is associated with the Apache server on the public network.  
   2. Paste the IP address into a web browser that has connectivity to the OpenStack public network.  
   3. Confirm the Apache server is running. You see the following message in the web browser:  
   ```
   Hello, world
   Success!
   ```

6. Set up the environment to invoke the IBM Telco Network Cloud Manager - Orchestration REST API.  
   1. Set the TNCO_URL environment variable to point to the API URL:  
   ```
   export TNCO_URL=<ishtar_route>
   ```  
   2. Set the TNCO_TOKEN environment variable to point to the access token
   ```
   export TNCO_TOKEN=<access_token>
   ```
   
   For more information about how to retrieve the ishtar_route and access_token parameters, see the topic _Invoking REST API_ in the [IBM Telco Network Cloud Manager - Orchestration Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSDSDC_1.3/welcome_page/kc_welcome-444.html).

7. Upload the apache-ansible-demo resource package to the IBM Telco Network Cloud Manager - Orchestration instance. You can upload resource packages and related descriptors using LMCTL or the REST API. In this example, the REST API commands are used to upload the resource package and related descriptors.
   1. Navigate to the _hw-apache-vnfc_ folder:
   ```
   cd ../../
   ```
   2. Create a zip file containing the resource package:
   ```
   zip -r  apache-ansible-demo .
   ```
   3. Upload the resource package to IBM Telco Network Cloud Manager - Orchestration:
   ```
   curl -sk -X POST "https://$TNCO_URL/api/resource-manager/resource-packages" -H 'Authorization: Bearer '"${TNCO_TOKEN}"'' -H 'Content-Type: multipart/form-data' -F "file=@./apache-ansible-demo.zip"
   ```  
8. Upload the resource and assembly descriptors to the IBM Telco Network Cloud Manager - Orchestration instance:
```
cd Definitions/lm
curl -sk -H 'Accept: */*' -X POST -H 'Content-Type: application/yaml' -H 'Authorization: Bearer '"${TNCO_TOKEN}"'' "https://$TNCO_URL/api/catalog/descriptors" --data-binary @./resource.yaml
cd ../../../../Descriptor
curl -sk -H 'Accept: */*' -X POST -H 'Content-Type: application/yaml' -H 'Authorization: Bearer '"${TNCO_TOKEN}"'' "https://$TNCO_URL/api/catalog/descriptors" --data-binary @./assembly.yml
```
9. Adopt the stack. Save the stack ID, the deployment location's name, and the name of the assembly that is created by the Adopt intent:
```
export ASSEMBLY_NAME=<adopted_assembly_name>
export DEPLOYMENT_LOCATION=<openstack_deployment_location>
export STACK_ID=<stack_id>
```
Start the Adopt REST API to adopt the stack:
```
curl -sk -0 -X POST "https://$TNCO_URL/api/intent/adoptAssembly" -H 'Authorization: Bearer '"${TNCO_TOKEN}"'' -H 'Content-Type: application/json' --data-binary @- << EOF
{
    "assemblyName": "$ASSEMBLY_NAME",
    "descriptorName": "assembly::apache-ansible-demo::1.0",
    "properties": {
        "resourceManager": "brent",
        "deploymentLocation": "$DEPLOYMENT_LOCATION"
    },
    "resources": {
        "${ASSEMBLY_NAME}__hw-apache": {
            "properties": {
            },
            "associatedTopology": [{
               "id": "$STACK_ID",
               "type": "openstack"
            }]
        }
    }
}
EOF
```

10. Verify that the stack is adopted successfully.  
    1. Open the IBM Telco Network Cloud Manager - Orchestration UI.  
    2. Click Recent Assembly Instances. You see the adopted assembly.  
    3. Open the Execution History of the adopted assembly. You see a completed successful adopt lifecycle intent.  
    4. Click Topology and verify that the public_ip property contains the Apache server IP address.  

11. Verify that the adopted assembly can be managed by IBM Telco Network Cloud Manager - Orchestration.  
    1. In the Topology View, click New Intent, and then click Make Inactive. This action triggers a Stop lifecycle transition that shuts down the Apache server.  
    2. After the transition completes, paste the IP address of the Apache server into a web browser that has connectivity to the OpenStack public network. Verify that the Apache server is no longer reachable. You receive an HTTP error status ERR_CONNECTION_REFUSED.  
    3. Restart the Apache server. Click New Intent and then click Make Active. Refresh the web browser page that points to the Apache server IP address. You see a message that indicates that the Apache server is up and running.
