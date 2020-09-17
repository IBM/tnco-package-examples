# Adopt Apache Demo

Assuming:

* you have onboarded the Openstack and Ansible drivers
* you have onboarded an Openstack deployment location (here called steve)
* your Openstack has an existing Apache stack already created e.g. by creating the stack in Openstack using the Apache heat template and you have the stack id (here it is 05ec1878-e920-488a-9e4e-76c5290a3813).
* you have uploaded the [Apache Demo Brent package](https://github.ibm.com/TNC/alm-package-examples/tree/master/assemblies/apache-demo) using lmctl

Then the Apache example can be adopted using the following REST Call against the Ishtar API:

```
POST https://[Fyre VM AIO IP]/api/intent/adoptAssembly
{
	"assemblyName": "apacheadopt1",
	"descriptorName": "assembly::apache-demo::1.0",
    "properties": {
        "resourceManager": "brent",
        "deploymentLocation": "steve"
    },
    "clusters": {
    },
	"resources": {
		"apacheadopt1__hw-apache": {
            "properties": {
            },
			"associatedTopology": [{
			     "id": "05ec1878-e920-488a-9e4e-76c5290a3813",
			     "name": "05ec1878-e920-488a-9e4e-76c5290a3813",
			     "type": "openstack"
			}]
		}
	}
}
```

Note that `apacheadopt1__hw-apache` properties is the mechanism for providing default properties per the requirement

> Should also include a provision to allow resource properties to be defined should it not be possible to retrieve these from the infrastructure during the Adopt transition

from the requirements document.

Note also the naming of the resource instance `apacheadopt1__hw-apache`, which is consistent with the naming of the resource instance if it had been created by LM.