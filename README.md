# Ansible Example

This repository contains a very simple ansible setup you can use to start. If you clone the git repository and navigate to the directory this README.md file is located you can run the following command to start an ansible run:

```
ansible-playbook --limit ts01 -i inventory/acceptation/hosts.yml playbooks/timeservers.yml
```

Before you start using the command make sure the hosts.yml file has the correct hostname(s) configured for your systems.

If you want to check the layout of your inventory (file) you can use the following command:

```
ansible-inventory -i inventory/acceptation/hosts.yml --list
```

This will provide you with an overview of the hosts and their parameters.

## Extensive example
The example directory contains a more extensive example of ansible and how you can use ansible. The more knowledgable ansible users can likely get the tree working. Start small if you have not used ansible yet and follow the tasks. You can use the extensive example as a reference.

If you have questions please ask them!
