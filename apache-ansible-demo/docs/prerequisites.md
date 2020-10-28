To run this resource package, you require the following prerequisites:

1. An OpenStack environment configured with a user, an associated project, a deallocated floating IP, an Ubuntu 18.04 QCOW2 images and a *Key Pair* called *default* available on the target project.  
2. For the Adopt lifecycle transition, an OpenStack stack in one of the following state: 'CREATE_COMPLETE','ADOPT_COMPLETE','RESUME_COMPLETE','CHECK_COMPLETE','UPDATE_COMPLETE'.  
3. * A flavor of specification m1.small defined in the OpenStack project. The flavor defines the compute, memory, and storage capacity of a virtual server, also known as an instance.

NOTE: Depending on your OpenStack HTTPS configuration, you may need to disable TLS certificates validation in the ansible playbooks. To do so, edit the files [Create.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Create.yaml), [Delete.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Delete.yaml) and [Adopt.yaml](./Contains/hw-apache-vnfc/Lifecycle/ansible/scripts/Adopt.yaml) and uncomment the *validate_certs* parameter.


