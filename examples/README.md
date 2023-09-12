# External roles/collections
Before running a play(book) make sure all required roles are installed.

```
ansible-galaxy install -r requirements.yml
```

# Run ansible setup from localhost to configure localhost

Clone the ansible code repo:
```
git clone [repo]
```

Run ansible for a specific role:
```
ansible-playbook -i inventory/production/hosts.yml plays/httpd.yml
```

Run ansible for a specific node (usefull for node specific runs not done remotely).

```
ansible-playbook --limit spl-vl-web20 -i inventory/acceptation/hosts.yml plays/httpd.yml
```
!! This requires that you have ansible installed locally and your inventory file/plays points to localhost!!

# Run Ansible from central node, and remotely configure nodes


You can specify in the inventory file how a node should connect to a host.
In the playbook you can overwrite the settings provided in the inventory file. Note the ../roles/internal/Common, normally ansible look for a roles directory relative to the inventory (file), so if you specify -i dir/inventory.yml the roles directory should be in the dir folder. If you want so specify an alternative path you could do it as shown below. The .. means go one directory up and then check for a roles folder there.
```
---
- hosts: '*'
  connection: ssh
  roles:
    - { role: ../roles/internal/Common, tags: ["cronjobs"] }
    - { role: ../roles/internal/Chrony, tags: ["chrony"] }
    - { role: robertdebock.openssh }
    - { role: robertdebock.snmpd }
    - { role: robertdebock.selinux }
    - { role: robertdebock.umask }
```
If you want a specific user to be used for setting up a connection and/or said use to use sudo for privilege escalation this can be defined for a given node in the inventory file, first an example using root:

```
all:
  webservers:
    hosts:
      javapp07:
        ansible_user: root
        ansible_host: spl-vl-web20.of.worlds.com
```

We prefer not to store password in plain-text so you can provide the --ask-pass parameter on the command line, in this case ansible will ask you to specify a password.

```
ansible-playbook --limit spl-vl-web20 -i inventory/acceptation/hosts.yml plays/httpd.yml --ask-pass
```

If you see the following error:

```
fatal: [spl-vl-web20]: FAILED! => {"msg": "to use the 'ssh' connection type with passwords or pkcs11_provider, you must install the sshpass program"}
```
you are missing the sshpass package.

```
sudo apt install sshpass
```
If you see the following error:

```
 "msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."
```

You have to disable ssh host_key checking for ansible. You can specify this via an ansible.cfg. If you have used the ppa and package manager, you will likely not encounter this problem. If you do check the ansible.cfg in /etc/ansible. In case you use pypi you can create an ansible.cfg and point to it. Please check the set_ansible_config.sh and ansible.cfg files in the directory.

The option below can become tedious if you are running ansible for multiple nodes. In this case its better (and safer) to use a (ansible) vault or hashicorp vault service.

# Using Vault

Ansible provides a mechanism called ansible-vault to securely store passwords in a file that is encrypted with AES-256 (by default).

With the following command a new vault file can be created:

```
ansible-vault create vault_acc.yml
```

A file can be viewed with the following command.

```
ansible-vault view vault_acc.yml
```

To edit the file use the following commmand:

```
ansible-vault edit vault_acc.yml
```

You can specify key:value pairs and assign them like normal variables in your file. Below is an example of the vault_acc.yml file:

```
web20_automator: [very-secret-pw]
global_maurice: [even-more-secret-pw]
```
You can now extend the inventory file to use these variables:

```
all:
  children:
    webservers:
      hosts:
        spl-vl-web20:
          ansible_user: automator
          ansible_host: spl-vl-web20.of.worlds.com
          ansible_ssh_pass: "{{ web20_automator }}"
          ansible_become: True
          ansible_become_method: sudo
          ansible_become_password: "{{ web20_automator }}"
```

To use the vault file during an ansible run the following command can be used:

```
ansible-playbook --limit spl-vl-web20 -i acceptation/hosts.yml plays/webservers.yml --ask-vault-pass --extra-vars '@vault_acc.yml'
                 --limit [only run ansible for this host]
                                      -i [inventory file, var dirs are relative to the directory of the inventory file]
                                                               [run this play(book)]
                                                                                    --ask-vault-pass
                                                                                                     --extra-vars [use this (vault) file to supply extra variables]

```
