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

## Task 1. **Install ansible on your ansiblecontroller{0x} and use this as your control node.**

In essense you have two (primary) methods to setup ansible.

**Method 1**: Use the package manager
The first is to use the package manager to install ansible on your control node:

```shell
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible
```

Advantage: Ansible is setup with a single command.
Disadvantage: Usually an older version

** Method 2**: Use python pip (in a virtual environment)
You could use python to setup a ansible. virtual environment 

```shell
# Create a virtualenv if one does not already exist
python -m virtualenv ansible

# Activate the virtual environment 
source ansible/bin/activate 

python -m pip install ansible
```

Advantage: Likelihood of installing (python) package that conflict with system required python packages is near zero.
Advantage: Allows you to setup the latest or multiple versions of Ansbile on the same node.
Advantage: You can create a identical setup across different Linux distributions
Disadvantage: More complex setup.

---
:memo: **Note**

If you install ansible using your package manager check the version of ansible that is installed. Older versions might have differences or the latest and greatest external roles/collections won't work!
  - The default ubuntu yammy ansible(-core) version is 2.10.8, if you want a newer version collect the ansible package from pypi (2.13.16) or the ppa ansible repository (2.13.6).
  - If you choose to use pypi a python virtual environment might help you!

---

## Task 2. **Prepare your ansible VMs.**
You need to prepare your VMs so that ansible can connect to the VMs. Ansible essentially needs an IP address or the name of a given node. As a name is more user friendly we will use this, however we do not have a DNS server running, we can update the hosts file on the controller to do the ip to name translation for us to connect to the ansible nodes.
- Update the /etc/hosts file of your ansiblecontroller with the names and ip addresses the nodes you are going to configure.

```shell
echo <ansiblenode0x ip address> <ansiblenode0x FQDN> >> /etc/hosts
# For example
echo 192.168.0.102 ansiblenode02.ansibleworkshop.sue.nl >> /etc/hosts
```

- Clone the repository with example to your controller node:

```shell
git clone https://github.com/Mandorath/ansible_workshop_101_sue.git
```

- Change into the cloned directory

```shell
cd ansible_workshop_101_sue
```

## Task 3. **Configure the ansiblenode0x in the inventory provided to you in the root of the GIT repository. Debug any problems you encounter when running ansible.**
Please check the inventory file, make sure the ansible host matches the DNS/host names of the VMs you added to the hosts file in task 2.
You can find the inventory file in inventory/acceptance/hosts.yml

```shell
# Use you editor of choice
nano inventory/acceptance/hosts.yml
# or
vi inventory/acceptance/hosts.yml
```

Modify the DNS names in the file, replace <ansiblenode0x.ansibleworkshop.sue.nl> with the DNS names you specified in the /etc/hosts file.

```yaml
all:
  childeren:
    timeservers:
      hosts:
        ts01:
          ansible_user: root
          ansible_host: <ansiblenode0x.ansibleworkshop.sue.nl>  <---- Replace this
        ts02:
          ansible_user: root
          ansible_host: <ansiblenode0x.ansibleworkshop.sue.nl> <----- Replace this
```

---
:memo: **Note**

It is not wise to specify a plaintext (root) password or use root in your inventory file to connect to remote nodes.
We do not wish to expose the root user of linux systems, many security benchmarks (or departments) require the root use to be blocked for SSH access.
If we can't use root we need to setup a new user. In our case I have taken the liberty to do this. All systems are equiped with an automator user.
You can find the password for this in the vault_demo.yml

Access this using the follwing command:

```shell
ansible-vault view vault_demo.yml
```
---

You can change the *ansible_user* to a different user, however that user is not root. In case you still need to execute privileged commands on a remote node Ansible needs to know how.
This could be achieved by *becoming* root or by using sudo. Check the example in examples/inventory/acceptance/hosts.yml to see how to specify the SSH password, how you could use sudo and how to specify a password for this.

In case you have finished your inventory you can check it using the following command:
```shell
ansible-inventory -i inventory/acceptation/hosts.yml --list
```

## Task 4. **Create an ansible task that adds your SSH key to the authorized keys of the in automated (sudo) user.**
  - Create or modify a file (ansible has modules for this) and add your ssh public key to the authorized_keys file.
  - There are multiple ways to approach this, you could manipulate the files uing the Ansible builtin tools or you could use another module for this.
    - https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html
    - The document describes how to install and use the module. The bottom of the page contains examples.


## Task 5. **Create an  ansible task that can install a package, install lsof and firewalld using this task.**
  - Hint; ansible has a module for this, look for apt module for ansible :-)

## Task 6. **Create an ansible task that installs and configures chrony. Make sure that chrony uses four of the dutch time servers (nl.pool.ntp.org).**
  - Hint; Maybe a jinja can help :-)

## Task 7. **Create a reusable ansible task/role that creates the users.**
  - shawn, uid=1800, group=spencer, make sure shawn has sudo access
  - burton, uid=1830, group=guster
  - carlton, uid=1840, group=lassiter
  - mary, uid=1850, group=lightly
  - Hint; something with conditionals.

## Task 8. **Install an ansible role from ansible-galaxy with which you can disable root password login for SSH and configures the motd banner for your SSH prompt.**
  - Hint; R. de bock might be able to help you.

## Task 9. **Create a second inventory for a production environment and configure your second VM using everything you created in the previous tasks.**
