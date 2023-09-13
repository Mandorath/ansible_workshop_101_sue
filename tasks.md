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

Access this using the following command:

```shell
ansible-vault view vault_demo.yml
```
---

You can change the *ansible_user* to a different user, however that user is not root. In case you still need to execute privileged commands on a remote node Ansible needs to know how.
This could be achieved by *becoming* root or by using sudo. Check the example in examples/inventory/acceptance/hosts.yml to see how to specify the SSH password, how you could use sudo and how to specify a password for this. For now you can add the password as plaintext into the hosts.yml file, ofcourse **never** to this for **any** environment, always use secure methods for providing the password!

In case you have finished your inventory you can check it using the following command:
```shell
ansible-inventory -i inventory/acceptation/hosts.yml --list
```

## Task 4. **Create an ansible play that installs and removes packages, install lsof, firewalld and remove the ufw package using one ore more tasks using variables.**
Create a new file in playbooks/ called my_playbook.yml

```shell
nano playbooks/my_playbook.yml
```

Create a new *play* by adding the following content, and modifying it to install or remove the aformentioned packages:

```yaml
---
- name: install and remove packages
  hosts: all
  become: yes
  gather_facts: yes
  tasks:
    - name: Install the lsof package
      ansible.builtin.apt:
        name: firewalld
        state: {{ firewalld_state }}   <-- absent = remove package, present = install package

```

Setup new variables in inventory/acceptance/group_vars/all/packages.yml

```yaml
firewalld_state: present
```

Repeat the steps above for the lsof and ufw packages.

---

:memo: **Note**
  - Ansible has a (builtin) module for this, look for apt module for ansible :-)
    - https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
  - There is also a very extensive (albeit somewhat complex) example in examples/roles/Common/tasks/apt_packages.yml

---

To run the playbook:

```
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml
```


Log into one of the ansible nodes and check if you can see if the packages are installed or removed:

```
sudo apt list firewalld
sudo apt list lsof
sudo apt list ufw
```

## Task 5. **Create an new playbook and ansible task that adds the controller node SSH key of the automator user to the authorized keys of the in automated (sudo) user.**

Add the following content to my_playbook.yml:

```yaml
- name: Add my authorized key
  hosts: all
  become: no
  gather_facts: yes
  tasks:
    - name: Add my ssh key to authorized key file.
      ansible.posix.authorized_key:
        user: <my_user>
        state: present
        key: "{{ lookup('file', '/home/<my_user>/.ssh/<my_key>') }}"
```

Create an ssh key for the automator user on the controller node:

```
ssh-keygen -t Ed25519
```

Create or modify a file (ansible has modules for this) and add the ssh public key of the automator user to the authorized_keys file of the ansiblenode{0x}.
    - You can find the public key of the automator user in ~/.ssh/id_ed25519.pub

There are multiple ways to approach this, you could manipulate the files uing the Ansible builtin tools or you could use another module for this. 
The posix collection contains a module to add an authorized key.
    - https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html
    - The document describes how to install and use the module. 
    - The bottom of the page contains examples.

Modify my_playbook.yml so it will pickup the ~/.ssh/id_ed25519.pub from the automator user.
Before you run the Ansible playbook make sure you have the Posix collection installed!!!!
To run the playbook:

```
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml
```

When you have run Ansible to deploy the SSH key, try to login to one of the nodes. You should not be prompted for a password.

```
ssh -l automator <ip address of ansible node>
```

## Task 6. **Create an ansible role that installs and configures chrony. Make sure that chrony uses four of the dutch time servers (nl.pool.ntp.org).**

Chrony is tool/daemon used on modern Linux systems to keep time synchronized. As we want to achieve complete managed of the chrony daemon we need several tasks to be done and a configuration file to be modified. To do this we can create a role. The examples/roles/internal/Chrony directory contains an example of a (simple) role to manage Chrony.

Copy the Chrony folder to the roles directory in the root of the workshop directory.

```
cp -r examples/roles/internalChrony roles/
```

Add the following play to your playbook

```yaml
- name: Configure Chrony
  hosts: timeservers
  become: yes
  gather_facts: yes

  roles:
    - { role: Chrony, tags: ["chrony"] }
```

---

:memo: **Note**
  - Chrony uses a configuration file that contains the settings it should use, including the ntp servers it should synchronize with.
  - We want to managed what is stored in said configuration file. You can utilize templates for this. By default Ansible uses jinja templates (jinja is a templating language) to render templates. You can see the below code in roles/Chrony/tasks/chrony.yml

```yaml
- name: Copy the chrony.conf
  template:
    src: chrony.conf.j2
    dest: "{{ chrony_configfile_path }}"
    owner: root
    group: root
    mode: 0664
```

You can see the template in roles/Chrony/templates/chrony.conf.j2, where the j2 extension indicates jinja2.

---

You can check the roles/Chrony/defaults/main.yml file. This file tends to contain a set of default variables.  

Add the variable that defines the chrony config servers to the inventory/acceptance/group_vars/timeservers.yml file. Then run the playbook.

Run the playbook:

```shell
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml
```

Log into on of the ansible nodes and check if the new servers are configured.

```shell
ssh -l automator <ip address of ansible node>
less /etc/chrony.conf
```

## Task 7. **Create a reusable ansible task/role that creates the users and groups specified below.

```
- shawn, uid=1800, group=spencer
- burton, uid=1830, group=guster
- carlton, uid=1840, group=lassiter
- mary, uid=1850, group=lightly
```

Create a new file in inventory/acceptance/group_vars/all/users.yml and define all the users as defined above:

```yaml
group:
  - name: spencer
    state: present
    system: no

user:
  - name: shawn
    group: spencer
    state: present
    password: "{{ <your password> | password_hash  }}"
    uid: 1800
```

Use the example above to specify the other users.

Create a new play in your my_playbook.yml:

```yaml
- name: Add my authorized key
  hosts: all
  become: no
  gather_facts: yes
  tasks:
    - name: create group {{ item.name}}
      user:
        name: "{{ item.name }}"
        gid: "{{ item.gid | default(omit) }}"
        local: "{{ item.local | default(omit) }}"
        state: "{{ item.state | default('present') }}"
        non_unique: "{{ item.non_unique | default(omit) }}"
        system: "{{ item.system | default(no) }}"
    - name: create user {{ item.name}}
      user:
        name: "{{ item.name }}"
        group: "{{ item.group | default(omit) }}"
        groups: "{{ item.groups | default(omit) }}"
        uid: "{{ item.uid | default(omit) }}"
        password: "{{ item.password | default(omit) }}"
      loop: "{{ user }}"
      loop_control:
        label: "{{ item.name }}"
      when: user is defined
```

---

:memo: **Note**
You see two filters being used here, one for creating hash which will be used instead of the plaintext password. The other is to provide a default value, in case a variable is not defined. However in this case a 'special' value is provided called *omit*, this omits the line if no variable with a value is provided. There are many, many more filters available. Take a look at the Ansible documentation for this.

https://docs.ansible.com/archive/ansible/2.3/playbooks_filters.html

---

Run the playbook:

```shell
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml
```

Log into on of the ansible nodes and check if the users are created.

```shell
ssh -l shawn <ip address of ansible node>
```

## Task 8. **Install an ansible role from ansible-galaxy with which you can disable root password login for SSH and configures the motd banner for your SSH prompt.**
We are going to install an external role add this to our playbook and run it with some variables we provide.

Run the command to install the external role:

```
ansible-galaxy install robertdebock.openssh
```

Now create a new variable file in inventory/acceptance/group_vars/all/openssh.yml and add the following contents:

```yaml
openssh_permit_root_login: "no"
openssh_banner: This is my fancy banner!
```

Now add the following to your playbook:

```yaml
---
- name:	setup ssh
  hosts: all
  connection: ssh
  roles:
    - { role: robertdebock.openssh, tags: ["ssh"] }
```

Run the playbook:

```shell
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml
```

Log into on of the ansible nodes and check if the banner has changed.

```shell
ssh -l automator <ip address of ansible node>
```

## Task 9. **Run only specific plays using a tag. Create a new vault file and add all your password to the vault file. Use the vault file in your ansible run.**


Run the ansible playbook 

```shell
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml --tag chrony
ansible-playbook -i inventory/acceptance/hosts.yml playbooks/my_playbook.yml --tag ssh
```

In both commands only the chrony or ssh play should run.


Try some of the test commands:

```shell 
# Debug the connection from your control host with the ping module
ansible -i <inventory_file> <pattern> -m ping

# Curious if your inventory correctly groups the hosts? Add the –list-hosts parameter
ansible -i <inventory_file> <pattern> --list-hosts 

# Alternatively you can print all the facts gathered by ansible for a set of hosts using the setup module
ansible -i <inventory_file> <pattern> -m setup

```

With all the knowledge you have learned I am going to let you try to setup Vault yourself. You can find information on setting up a vault file in examples/README.md
