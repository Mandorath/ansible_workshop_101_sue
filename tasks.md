### Colloquium Workshop Excercises

https://github.com/Mandorath/ansible_workshop_101_sue.git

The setup we will use:
```

                  -----------------------
                  | ansiblecontroller0x |
                  | (Control node)      |
                  -----------------------
                   /                     \
                  /                       \
              (SSH)                      (SSH)
                /                           \
  --------------------                --------------------
  |   ansiblenode0x  |                |   ansiblenode0x  |
  --------------------                --------------------
```

You will have three nodes available:
  - ansiblecontroller0x  --> We will install Ansible here and use it to configure the other nodes
  - ansiblenode0x        --> Node we will configure
  - ansiblenode0x        --> Node we will configure

Task 1. **Install ansible on your ansiblecontroller{0x} and use this as your control node.**

In essense you have two primary methods to setup ansible. The first is to use the package manager to install ansible on your control node:

```
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible
```

Or you could use python to 

```
# Create a virtualenv if one does not already exist
python -m virtualenv ansible

# Activate the virtual environment 
source ansible/bin/activate 

python -m pip install ansible
```
Name an advantage and disadvantage of each of the methods.

Hint; if you install ansible using your package manager check the version of ansible that is installed. Older versions might have differences or the latest and greatest external roles/collections won't work!
  - The default ubuntu yammy ansible(-core) version is 2.10.8, if you want a newer version collect the ansible package from pypi (2.13.16) or the ppa ansible repository (2.13.6).
  - If you choose to use pypi a python virtual environment might help you!

Task 2. **Prepare your ansible VMs.**
You need to prepare your VMs so that ansible can connect to the VMs. Ansible essentially needs an IP address the name of a given node. As a name is more user friendly we will use this, however we do not have a DNS server running, we can update the hosts file on the controller to do the ip to name translation for us to connect to the ansible nodes.
  - Update the hosts file of your ansiblecontroller with the names and ip addresses the nodes you are going to configure.

```
echo <ansiblenode0x ip address> <ansiblenode0x FQDN> >> /etc/hosts
# For example
echo 192.168.0.102 ansiblenode02.ansibleworkshop.sue.nl >> /etc/hosts
```

- Clone the repository with example to your controller node:

```
git clone https://github.com/Mandorath/ansible_workshop_101_sue.git
```

- Change into the directory

```
cd ansible_workshop_101_sue
```

Task 3. **Configure the ansiblenode0x in the inventory provided to you in the root of the GIT repository. Debug any problems you encounter when running ansible.**
  - Please check the inventory file, make sure the ansible host matches the DNS/host names of the VMs created in task 2.
    - You can find the inventory file in inventory/acceptance/hosts.yml

```
# Use you editor of choice
nano inventory/acceptance/hosts.yml
```

  - Is it wise to specify a plaintext (root) password or use root in your inventory file? 
    - Find a way to circumvent this and still run ansible with the required privileges.
    - Hint; become sudo.

```
```

```
ansible-inventory --list -y
```

Task 4. **Create an ansible task that adds your SSH key to the authorized keys of the in task 3 created sudo user.**
  - Create or modify a file (ansible has modules for this) and add your ssh public key to the authorized_keys file.
  - Hint; ansible has a module for this.


5. **Create an  ansible task that can install a package, install lsof and firewalld using this task.**
  - Hint; ansible has a module for this :-)

6. **Create an ansible task that installs and configures chrony. Make sure that chrony uses four of the dutch time servers (nl.pool.ntp.org).**
  - Hint; Maybe a jinja can help :-)

7. **Create a reusable ansible task/role that creates the users.**
  - shawn, uid=1800, group=spencer, make sure shawn has sudo access
  - burton, uid=1830, group=guster
  - carlton, uid=1840, group=lassiter
  - mary, uid=1850, group=lightly
  - Hint; something with conditionals.

8. **Install an ansible role from ansible-galaxy with which you can disable root password login for SSH and configures the motd banner for your SSH prompt.**
  - Hint; R. de bock might be able to help you.

9. **Create a second inventory for a production environment and configure your second VM using everything you created in the previous tasks.**
