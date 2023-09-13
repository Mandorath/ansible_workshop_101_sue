# Ansible Example

This repository contains a very simple ansible setup you can use to start. If you clone the git repository and navigate to the directory this README.md file is located you can run the following command to start an ansible run:

```
ansible-playbook --limit ts01 -i inventory/acceptance/hosts.yml playbooks/timeservers.yml
```

*ansible-playbook* - The command to run an ansible play(book)
*--limit* - instructs Ansible to run the playbook **only** for the specified node(s), in this case ts01
*playbooks/timeservers.yml* - you always end ith the playbook you want to run.

Before you start using the command make sure the hosts.yml file has the correct hostname(s) configured for your systems.

If you want to check the layout of your inventory (file) you can use the following command:

```
ansible-inventory -i inventory/acceptance/hosts.yml --list
```

This will provide you with an overview of the hosts and their parameters.

## Extensive example
The example directory contains a more extensive example of ansible and how you can use ansible. The more knowledgable ansible users can likely get the tree working. Start small if you have not used ansible yet and follow the tasks. You can use the extensive example as a reference.

```
examples/
  |
  --inventory/            --> contains the inventories of nodes.
  |
  --playbooks/            --> contains playbooks that detail (repeatable) tasks that configure a specific 'thing'
  |
  --roles/                --> contains
  |
  --venv_setup            --> not part of ansible, but contains a script to helpt setyp a python virtual environment.
  | 
  --ansible.cfg           --> contains specific ansible configuration options
  |
  --requirements.yml      --> contains ansible external dependencies that e.g. external roles or collections that need to be installed.
  |
  --set_ansible_config.sh --> Bash script to activate the (custom) ansible.cfg file.
  |
  --setup_ansible_venv.sh --> Bash script to create a python virtual environment with ansible installed in it.
  |
  --vault_acc.yml         --> A (AES256) encrypted file that can be used to store secret data e.g. passwords.
```

If you have questions please ask them!
