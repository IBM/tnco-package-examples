## Overview
This repository contains the implementation of a resource package for IBM Telco Network Cloud Manager Orchestration that creates and manage an Apache server on OpenStack.
The lifecycle of the resources contained in the resource package is entirely managed by the Ansible Lifecycle Driver.

## Content:
[Content of the resource package](#Content-of-the-resource-package)  
[Prerequisites to run the resource package](#Prerequisites-to-run-the-resource-package)
[Installing the resource package](#Installing-the-resource-package)  

### Content of the resource package
The resource package contains resource definitions and scripts that allow to manage an Apache server on OpenStack through the Ansible Lifecycle Driver.

The package contains the descriptor of an assembly ([apache-ansible-demo](./Descriptor/assembly.yml)) and of a resource ([hw-apache](./Contains/hw-apache-vnfc/Definitions/lm/resource.yaml)).  
The resource descriptor defines properties of the Apache server and of the underlying infrastructure. It also defines the characteristics of the lifecycle execution that is used to manage the resource.  
The lifecycle definition indicates that Adopt, Create, Configure, Install, Start, Stop and Delete intents are defined for the resource and that are managed by the Ansible Lifecycle Driver.  
  
The OpenStack infrastructure that hosts the Apache server is defined by the [HEAT template](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Openstack/heat.yaml).  
  
The lifecycle execution is implemented by [the ansible playbooks](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts). When an intent is issued against the resource, the Ansible Lifecycle Driver invokes the corresponding ansible playbook.
The ansible playbooks use artefacts in the package and properties passed by the Ansible Lifecycle Driver to execute the lifecycle transition.  
For example, to create the OpenStack infrastructure, the Create playbook uses the HEAT template and passes Ansible Lifecycle Driver properties as the input parameters to the template.
  
A set of [bash scripts](./Contains/hw-apache-vnfc/Lifecycle/scripts) allow to invoke the ansible playbooks from command line. This can be useful to test alterations to the playbooks before installing the resource package.  

### Prerequisites to run the resource package
The OpenStack environment must have the Ubuntu 18.04 QCOW2 images and a *Key Pair* called *default* available on the target project.
In order to be able to adopt a stack, the stack must be in one of the following state: 'CREATE_COMPLETE','ADOPT_COMPLETE','RESUME_COMPLETE','CHECK_COMPLETE','UPDATE_COMPLETE'.
Depending on the OpenStack HTTPS configuration, you may want to disable SSL certificates validation in the ansible playbooks invoking the OpenStack REST API. To do that, edit the files [Create.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Create.yaml), [Delete.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Delete.yaml) and [Adopt.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Adopt.yaml) and uncomment the *validate_certs* parameter.
### Installing the resource package
To install the resource package both REST API and [lmctl](https://github.com/IBM/lmctl) tool can be used.  
The following instructions describe the resource package installation using the lmctl tool. Refer to the IBM Telco Network Cloud Manager Orchestration documentation for details on how to install a resource package using REST API.

* Install and configure the lmctl tool:  
Follow the [installation instructions](https://github.com/IBM/lmctl/blob/master/docs/install.md) to install and configure the lmctl tool.  
  
* Clone the TNC-O package examples repository:  

```
git clone https://github.com/IBM/tnco-package-examples
```
  
* Retrieve the TNC-O environment on which to install the resource package:  

```
lmctl env list
```
  
* Install the Apache Ansible Demo resource package:  

```
cd tnco-package-examples/apache-ansible-demo
lmctl project push <tnco-environment-name> 
```
  
