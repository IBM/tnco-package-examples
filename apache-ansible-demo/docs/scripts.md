The set of the scripts in the [scripts folder](../Contains/hw-apache-vnfc/Lifecycle/scripts) allows to invoke the resource package's playbooks from command line.

The scripts can run on any host where ansible, openstacksdk, sshpass are installed. The OpenStack environment must have the Ubuntu 18.04 QCOW2 images and a Key Pair called *default* available on the target project.

Before running the scripts, you must edit them and set the environment variables at the top of the script appropriately.

By default, the scripts create.sh, adopt.sh and delete.sh run the playbooks on localhost. You can run the playbooks on a different host by setting the optional variables REMOTE_HOST, REMOTE_USER, REMOTE_PASSWORD

In order for the playbooks to connect via ssh to the Apache VM, you may need to set up a jump host that has connectivity to the Apache VM. To set up a jump host, you can specify the optional variables JUMPHOST_IP, JUMPHOST_USER, JUMPHOST_PASSWORD. Additionally, you may need to set the environment variable ANSIBLE_HOST_KEY_CHECKING to False or to remove host entries from the known_hosts file, to prevent ssh from checking hosts identification.

The create.sh script automates the execution of a stack lifecycle corresponding to the creation of the stack through an assembly. This means that after the Create playbook, the Install, the Configure and the Start playbooks are executed.

The create.sh script can take several minutes to complete.
