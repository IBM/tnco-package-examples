## Adopting an Openstack Stack
This example shows how to use this resource package, _IBM® Telco Network Cloud - Orchestration_ and the _OpenStack VIM driver_ to adopt a stack in OpenStack. 

### Before beginning

To follow this example, the following prerequisites are required:
* OpenShift Container Platform (OCP) 4.5 or later.
* IBM Telco Network Cloud - Orchestration Version 1.3.0 that is installed and ready on an OCP system.
* [LMCTL v2.5.0+](https://github.com/IBM/lmctl) installed on a client computer and configured to communicate with an _IBM Telco Network Cloud - Orchestration_  instance.
* OpenStack and Ansible Drivers that are installed and running in IBM Telco Network Cloud - Orchestration.
* An OpenStack environment with available compute nodes and floating IP addresses. For testing, DevStack may be used.
  
##### OpenStack environment requires the following prerequisites:
* A flavor of specification `m1.small`. The flavor defines the compute, memory, and storage capacity of a virtual server, also known as an instance.
* A compute instance image with SSH password access support: xenial-server-cloudimg-amd64-disk1. This image is included with a standard DevStack installation or it mayb be downloaded it from Ubuntu.
* A public network that is included with a standard DevStack installation.
* A key-pair named default of type SSH Key to be used by compute instances. This can be created through the OpenStack dashboard.
  
##### IBM Telco Network Cloud - Orchestration environment requires the following drivers and deployment location:
* The latest [OpenStack VIM Driver](https://github.com/IBM/openstack-vim-driver/releases/) installed and on-boarded.
* The latest [Ansible Lifecycle Driver](https://github.com/IBM/ansible-lifecycle-driver/releases) installed and on-boarded.
* A valid Deployment Location on-boarded to _IBM Telco Network Cloud - Orchestration_ with the necessary properties that are required by the OpenStack VIM Driver and the Ansible Lifecycle Driver.
  
### About this task
This task comprises the following primary steps:
* Creating a stack in OpenStack to Adopt.
* Onboarding OpenStack location in IBM Telco Network Cloud - Orchestration.
* Uploading the Apache Demo Resource Package.
* Adopting the stack by way of the Rest API.

### Procedure
1. The first task is to create a stack in OpenStack independently of IBM Telco Network Cloud - Orchestration so that it can be adopted in to IBM Telco Network Cloud - Orchestration. To create a stack, use, for example, the OpenStack command-line client that is available on the OpenStack system. Alternatively, the command-line client can be installed on to a local computer that has access to the OpenStack address.  

For more information about installing OpenStack command-line clients, including troubleshooting openstack tools, see [here](https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html).

2. Create the stack by using the heat template file that is bundled as part of the Apache demo assembly example, [heat.yaml] (../Contains/hw-apache-vnfc/Lifecycle/Openstack/heat.yaml). 

    1. Use the following command to create the stack: 
    ```
    openstack --insecure stack create apachedemo --parameter "key_name=default;image_id=xenial-server-cloudimg-amd64-disk1;flavor=m1.small" -t tnco-package-examples/apache-demo/Contains/hw-apache-vnfc/Lifecycle/Openstack/heat.yaml
    ```
    
    The command returns output similar to the following example. Make a note of the ID value as it is needed to adopt the stack later. It can also be retrieved from the OpenStack UI.
    ```
    | Field               | Value                                      |
    |---------------------|--------------------------------------------|
    | id                  | 5265adec-503e-4e8a-885a-91ba99ee57b0       |
    | stack_name          | apachedemo                       |
    | description         | Base infrastructure for an Apache2 example |
    | creation_time       | 2020-09-18T13:54:59Z                       |
    | updated_time        | None                                       |
    | stack_status        | CREATE_IN_PROGRESS                         |
    | stack_status_reason | Stack CREATE started                       |
   ```   
    2. Check that the OpenStack stack is created successfully by entering:
    ```
    openstack stack list -c "ID" -c "Stack Name" -c "Stack Status"
    ```
3. To communicate with the OpenStack Cluster, on-board it as a deployment location in IBM Telco Network Cloud - Orchestration.
    1. Log in to _IBM Telco Network Cloud - Orchestration_ UI.
    2. From the navigation, select Deployment Locations.
    3. Click Add.
    4. Enter a name for the location.
    5. For the Resource Manager field, select Brent.
    6. For the Infrastructure field, select OpenStack.
    7. Add infrastructure properties. These properties are available from the OpenStack system's RC file, found under the API section in OpenStack. For example, see these sample values:
    ```
    "os_auth_project_name": "test",
    "os_auth_project_domain_name": "default",
    "os_auth_username": "admin",
    "os_auth_password": "password",
    "os_auth_user_domain_name": "Default",
    "os_auth_api": "identity/v3",
    "os_api_url": "http://9.46.89.226",
    "os_auth_project_id": "701600a059af40e1865a3c494288712a"
    ```
    8. Click Save.
4. Upload the apache-demo resource package to the IBM Telco Network Cloud - Orchestration instance. The resource package contains the apache-demo assembly descriptor, the resource descriptor for the Apache2 server, a heat template, and configuration files. 
> **Note:** Resource packages and related descriptors can be uploaded using LMCTL or the REST API. 
In this example, LMCTL is used to upload the resource package and related descriptors. 

  To upload the demo resource package, follow these steps:  
  - Clone the TNC-O package examples repository:
  ```
  git clone https://github.com/IBM/tnco-package-examples
  ```
  - Retrieve the TNC-O environment on which to install the resource package:
  ```
  lmctl env list
  ```
  - Install the Apache Demo resource package:
  ```
  cd tnco-package-examples/apache-demo
  lmctl project push <tnco-environment-name> 
  ```
5. Adopt the stack by way of the TNC-O REST API. For this procedure, use the curl CLI commands to access the _IBM Telco Network Cloud - Orchestration_ API. Set up the environment to invoke the IBM Telco Network Cloud Manager - Orchestration REST API.  
   1. Set the TNCO_URL environment variable to point to the API URL:  
   ```
   export TNCO_URL=<ishtar_route>
   ```  
   2. Set the TNCO_TOKEN environment variable to point to the access token
   ```
   export TNCO_TOKEN=<access_token>
   ```
   
  For more information about how to retrieve the ishtar_route and access_token parameters, see the topic _Invoking REST API_ in the [IBM Telco Network Cloud Manager - Orchestration Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSDSDC_1.3/welcome_page/kc_welcome-444.html).

6. Run the Adopt API call to bring the stack under IBM Telco Network Cloud - Orchestration control.  
    1. Use the following JSON data to adopt the OpenStack stack created in the previous step:
   ```
            {
                "assemblyName": "apacheadopt",
                "descriptorName": "assembly::apache-demo::1.0",
                "properties": {
                    "resourceManager": "brent",
                    "deploymentLocation": "test-openstack"
                }, 
                "clusters": {
                },
                "resources": {
                    "apacheadopt__hw-apache": {
                        "properties": {
                        },
                        "associatedTopology": [{
                            "id": "5265adec-503e-4e8a-885a-91ba99ee57b0",
                            "type": "openstack"
                        }]
                    }
                }
            }
      ```
        **Note:** The resource name under resources conforms to the standard resource instance name syntax, that is, a string of components separated by __ characters. Each component represents a component in the descriptor or a number for clustered components, starting with the assembly instance name. In this example, hw-apache is found in the apache-examples/apache-demo/Descriptor/assembly.yml descriptor.
    2. Save the JSON content to a file named adoptRequest.json and modify the fields assemblyName, deploymentLocation, resources, and associatedTopology.id as necessary.
    3. Adopt the stack by using the following REST API call against the API:
    ```
    curl -v --insecure -X POST -H "Authorization: Bearer $TNCO_TOKEN" -H "Content-Type: application/json" https://$TNCO_URL:443/api/intent/adoptAssembly -d @adoptRequest.json
    ```
7. Check the status of the adopt intent in the IBM Telco Network Cloud - Orchestration User Interface.
If the adopt API request is accepted, an HTTP 201 response is returned. At this point, the assembly appears in the Recent Assembly Instances view of the IBM Telco Network Cloud - Orchestration UI. The progress of the adopt intent can be monitored by opening the assembly and selecting the Execution tab.
The Apache assembly is successfully adopted and is under the control of IBM Telco Network Cloud - Orchestration. It is in the Active state. However, the adopt intent does not start the Apache Server and it was not started manually.

8. Start the Apache server. To start the Apache server, stop and restart it in the IBM Telco Network Cloud - Orchestration UI.  
    1. Select the apacheadopt assembly instance from Recent Assembly Instances.
    2. Click New intent, and select Make Inactive.
    3. Click New intent, and select Make Active.
    This step ensures that the Apache server starts. To verify it is successfully running, enter the public IP address of the adopted assembly in a browser. The Apache server landing page should be seen.</ul>
    
   **Note:** The public IP address can be found in the properties section for the assembly when opened in the _IBM Telco Network Cloud - Orchestration_ UI.

9. Finally, because the Apache assembly is now under the control of _IBM Telco Network Cloud - Orchestration_, it can be deleted from within _IBM Telco Network Cloud - Orchestration_.  
To delete the apacheadopt assembly instance, click _New Intent_ and select Uninstall.  
The stack will be removed in OpenStack.
