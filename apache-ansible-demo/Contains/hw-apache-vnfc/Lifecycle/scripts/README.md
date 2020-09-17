### Scripts to invoke playbooks from command line.

The set of scripts in this folder allows to invoke the playbooks created to manage OpenStack resources through an ALM resource package.

The scripts can run on any host where *ansible* and *sshpass* are installed.

Before running the scripts, you must edit the scripts and set appropriately the environment variables that are described at the top of each script. 

By default, the scripts *create.sh*, *adopt.sh* and *delete.sh* run the playbooks on localhost. If you want to run the playbooks on a different host you can set the optional variables *REMOTE_HOST*, *REMOTE_USER*, *REMOTE_PASSWORD*

In order for the playbooks to ssh to the apache vm, created in the OpenStack stack, for some of the scripts you may need to set up a jump host to point to a host that is in the same subnet and that can reach the apache vm.
To set up a jump host, you need to set the optional variables *JUMPHOST_IP*, *JUMPHOST_USER*, *JUMPHOST_PASSWORD*.

The *create.sh* script automates the execution of a stack lifecycle corresponding to the creation of the stack through an ALM assembly. This means that after the Create playbook, the Install, the Configure and the Start playbooks are executed.

The *create.sh* script can take more than 15 minutes.