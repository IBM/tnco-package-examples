The resource package contains resource definitions and scripts that allow to manage an Apache server on OpenStack through the Ansible Lifecycle Driver.

The package contains the descriptor of an assembly ([apache-ansible-demo](../Descriptor/assembly.yml)) and of a resource ([hw-apache](../Contains/hw-apache-vnfc/Definitions/lm/resource.yaml)).  
The resource descriptor defines properties of the Apache server and of the underlying infrastructure. It also defines the characteristics of the lifecycle execution that is used to manage the resource.  
The lifecycle definition indicates that Adopt, Create, Configure, Install, Start, Stop and Delete lifecycle transitions are defined for the resource and that are managed by the Ansible Lifecycle Driver.  
  
The OpenStack infrastructure that hosts the Apache server is defined by the [HEAT template](../Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Openstack/heat.yaml).  
  
The lifecycle execution is implemented by [the ansible playbooks](../Contains/hw-apache-vnfc/Lifecycle/ansible/scripts). When an intent is issued against the resource, the Ansible Lifecycle Driver invokes the corresponding ansible playbook.
The ansible playbooks use artefacts in the package and properties passed by the Ansible Lifecycle Driver to execute the lifecycle transition.  
For example, to create the OpenStack infrastructure, the Create playbook uses the HEAT template and passes Ansible Lifecycle Driver properties as the input parameters to the template.
  
A set of [bash scripts](../Contains/hw-apache-vnfc/Lifecycle/scripts) allow to invoke the ansible playbooks from command line. This can be useful to test alterations to the playbooks before installing the resource package. For details on how to run the bash scripts, refer to [the documentation](./scripts.md).
