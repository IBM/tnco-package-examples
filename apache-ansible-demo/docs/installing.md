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
