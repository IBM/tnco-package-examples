This example shows you how to use this resource package, IBM® Telco Network Cloud - Orchestration and the OpenStack VIM driver to adopt a stack in OpenStack. 

### Before you begin
The variables that are used in this procedure are described in the following table:

*Table 1. Variables used in this procedure*

| Variable	| Description |
|---|---|
| $NAMESPACE | The namespace in which IBM Telco Network Cloud - Orchestration is installed. For example, lifecycle-manager. |
| $PROXY_ADDRESS | Public API address, for example, alm-ishtar-lifecycle-manager.ocp.ibm.com.| 
| $CLIENT_ID	API | username. Admin by default.| 
| $CLIENT_SECRET	| The key for $CLIENT_ID.| 
| $BASIC_AUTH_ENCODED	| The encoded header for basic authorization.| 
| $ACCESS_TOKEN	| The token for OAuth authentication.|   
  
To follow this procedure, you require the following prerequisites:
* OpenShift Container Platform (OCP) 4.5 or later.
* IBM Telco Network Cloud - Orchestration Version 1.3.0 that is installed and ready on an OCP system.
* LMCTL v2.5.0+ installed on a client computer and configured to communicate with your IBM Telco Network Cloud - Orchestration instance.
* OpenStack and Ansible Drivers that are installed and running in IBM Telco Network Cloud - Orchestration.
* An OpenStack environment with available compute nodes and floating IP addresses. For testing, you can use DevStack.
  
Your OpenStack environment requires the following prerequisites:
* A flavor of specification m1.small. The flavor defines the compute, memory, and storage capacity of a virtual server, also known as an instance.
* A compute instance image with SSH password access support: xenial-server-cloudimg-amd64-disk1. This image is included with a standard DevStack installation or you can download it from Ubuntu.
* A public network that is included with a standard DevStack installation.
* A key-pair named default of type SSH Key to be used by compute instances. You can create one through the OpenStack dashboard.
  
Your IBM Telco Network Cloud - Orchestration environment requires the following drivers and deployment location:
* The latest OpenStack VIM Driver installed and on-boarded.
* The latest Ansible Lifecycle Driver installed and on-boarded.
* A valid Deployment Location on-boarded to IBM Telco Network Cloud - Orchestration with the necessary properties that are required by the OpenStack VIM Driver and the Ansible Lifecycle Driver.
  
### About this task
This task comprises the following primary steps:
* Creating a stack in OpenStack to Adopt.
* Onboarding OpenStack location in IBM Telco Network Cloud - Orchestration.
* Uploading the Apache Demo Resource Package.
* Adopting the stack by way of the Rest API.

### Procedure
1. The first task is to create a stack in OpenStack independently of IBM Telco Network Cloud - Orchestration so that it can be adopted in to IBM Telco Network Cloud - Orchestration. To create a stack, use, for example, the OpenStack command-line client that is available when you ssh on to the OpenStack system. Alternatively, you can install these components on to a local computer that has access to the OpenStack address.  
To install the OpenStack command-line client locally, run the following command:
```
pip install python-openstackclientCopy code
```
For more information about installing OpenStack command-line clients, including troubleshooting openstack tools, see Install the OpenStack command-line clients.

2. Create the stack by using the heat template file that is bundled as part of the Apache demo assembly example under the tnco-package-examples/apache-demo/Contains/hw-apache-vnfc/Lifecycle/Openstack/heat.yaml file. You must download and source the OpenStack RC file from the OpenStack server in the API Access section before you can enter openstack commands against your instance.
    1. Use the following command to create the stack: 
    ```
    openstack [--insecure] stack create apachedemo --parameter "key_name=default;image_id=xenial-server-cloudimg-amd64-disk1;flavor=m1.small" -t tnco-package-examples/apache-demo/Contains/hw-apache-vnfc/Lifecycle/Openstack/heat.yaml
    ```
    If you see an error for the heat template version (on older OpenStack systems), change the heat_template_version in the heat.yaml file to 2018-03-02.  
    The command returns output similar to the following example. Make a note of the ID value because you need it for adopt       later. It can also be retrieved from the OpenStack UI.
    | Field               | Value                                      |
    |---------------------|--------------------------------------------|
    | id                  | 5265adec-503e-4e8a-885a-91ba99ee57b0       |
    | stack_name          | apachedemo                       |
    | description         | Base infrastructure for an Apache2 example |
    | creation_time       | 2020-09-18T13:54:59Z                       |
    | updated_time        | None                                       |
    | stack_status        | CREATE_IN_PROGRESS                         |
    | stack_status_reason | Stack CREATE started                       |
   
    2. Check that the OpenStack stack is created successfully by entering:
    ```
    openstack stack list -c "ID" -c "Stack Name" -c "Stack Status"Copy code
    ```
3. To communicate with your OpenStack Cluster, on-board it as a deployment location in IBM Telco Network Cloud - Orchestration.
    1. Log in to your IBM Telco Network Cloud - Orchestration UI.
    2. From the navigation, select Deployment Locations.
    3. Click Add.
    4. Enter a name for the location.
    5. For the Resource Manager field, select Brent.
    6. For the Infrastructure field, select OpenStack.
    7. Add infrastructure properties. These properties are available from your OpenStack's RC file, found under the API section in OpenStack. For example, see these sample values:
    ```
    "os_auth_project_name": "test",
    "os_auth_project_domain_name": "default",
    "os_auth_username": "admin",
    "os_auth_password": "password",
    "os_auth_user_domain_name": "Default",
    "os_auth_api": "identity/v3",
    "os_api_url": "http://9.46.89.226",
    "os_auth_project_id": "701600a059af40e1865a3c494288712a"Copy code
    ```
    8. Click Save.
4. Upload the Apache Demo Resource Package. The resource package contains the apache-demo assembly descriptor, the resource descriptor for the Apache2 server, a heat template, and configuration files. For an example resource package, see IBM/tnco-package-examples/Apache-demo.  
You upload the demo resource package to IBM Telco Network Cloud - Orchestration by using the lmctl command-line tool. For more information about the lmctl command-line tool, see https://github.com/IBM/lmctl).  
To upload the demo resource package, follow these steps:  
    1. Unpack the package-examples on the client computer where lmctl is installed and configured.
    2. Browse to the tnco-package-examples/apache-demo directory.
    3. Push the assembly to IBM Telco Network Cloud - Orchestration with the following command:
    ```
    lmctl project push env
    ```
    Where env is the name of your IBM Telco Network Cloud - Orchestration environment that you set up in your lmctl configuration.  
  
5. Adopt the stack by way of the REST API. For this procedure, use the curl CLI commands to access the IBM Telco Network Cloud - Orchestration API.
To access the REST API, retrieve an Access Token for Authorization.

    **Note:** The first three steps must be done on the OCP system, or a client where you have access to the OC command to get the CLIENT_SECRET. The subsequent steps can be continued from there or from another client.
    
    1. Set the following initial environment variables: the name of the namespace, the name of the secret that holds the IBM Telco Network Cloud - Orchestration credentials, and the CLIENT_ID as Admin:
    ```
    NAMESPACE=lifecycle-manager
    TNCO_CREDENTIALS_SECRET=alm-credentials-default
    CLIENT_ID=AdminCopy code
    ```
    2. Get the $CLIENT_SECRET is the key for clientId: Admin and decode it using base64.
    ```
    CLIENT_SECRET=$(oc get secret $TNCO_CREDENTIALS_SECRET -o jsonpath='{.data.adminClientSecret}' -n $NAMESPACE | base64 -d)
    ```
    3. Fetch the API PROXY_ADDRESS (Ishtar route):
    ```
    PROXY_ADDRESS=$(oc get routes alm-ishtar -o jsonpath='{.spec.host}' -n $NAMESPACE)Copy code
    ```
    4. Set an encoded header for basic authorization:
    ```
    BASIC_AUTH_ENCODED=$(echo -n "$CLIENT_ID:$CLIENT_SECRET" | base64)
    ```
    5. Generate the ACCESS_TOKEN that is required for OAuth authentication:
    ```
    ACCESS_TOKEN=$(curl -sk -X POST "https://$PROXY_ADDRESS/oauth/token" -H "Authorization: Basic $BASIC_AUTH_ENCODED" -d 'grant_type=client_credentials' | python -c 'import sys, json; print json.load(sys.stdin)["access_token"]')
    ```
    You can test the access token by calling the API to list the assemblies, for example:
    ```
    curl --insecure -H 'Accept: */*' -X GET -H "Authorization: Bearer $ACCESS_TOKEN" https://$PROXY_ADDRESS:443/api/topology/assemblies
    ```
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
                    "id": "5265adec-503e-4e8a-885a-91ba99ee57b0 ",
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
    curl -v --insecure -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" https://$PROXY_ADDRESS:443/api/intent/adoptAssembly -d @adoptRequest.json
    ```
7. Check the status of the adopt intent in the IBM Telco Network Cloud - Orchestration User Interface.
If the adopt API request is accepted, an HTTP 201 response is returned. At this point, the assembly appears in the Recent Assembly Instances view of the IBM Telco Network Cloud - Orchestration UI. The progress of the adopt intent can be monitored by opening the assembly and selecting the Execution tab.
The Apache assembly is successfully adopted and is under the control of IBM Telco Network Cloud - Orchestration. It is in the Active state. However, the adopt intent does not start the Apache Server and it was not started manually.

8. Start the Apache server. To start the Apache server, stop and restart it in the IBM Telco Network Cloud - Orchestration UI.
    1. Select the apacheadopt assembly instance from Recent Assembly Instances.
    2. Click New intent, and select Make Inactive.
    3. Click New intent, and select Make Active.
    This step ensures that the Apache server starts. To verify it is successfully running, enter the public IP address of the adopted assembly in a browser. You see the Apache server landing page.
    **Note:** The public IP address can be found in the properties section for the assembly when you open it in the IBM Telco Network Cloud - Orchestration UI.
  
9. Finally, because the Apache assembly is under the control of IBM Telco Network Cloud - Orchestration, you can delete it from IBM Telco Network Cloud - Orchestration.  
To delete the apacheadopt assembly instance, click New intent, and select Uninstall.  
The stack is removed in OpenStack.