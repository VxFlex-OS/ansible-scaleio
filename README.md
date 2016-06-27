ansible-scaleio
===============

ansible-scaleio is a way to manage [ScaleIO](http://www.emc.com/storage/scaleio/index.htm "ScaleIO") through [Ansible](http://www.ansible.com/home "Ansible").

## Description

ansible-scaleio let's you do the following with Ansible (version 2 is supported) and ScaleIO:

- Install ScaleIO

- Configure the different roles:
  - mdm
  - sds
  - tb
  - lia
  - callhome (for version 1.3x only)
  - gateway (to be used for API gateway mainly)
  - sdc
  - gui

- For the sds you can setup different type of storage.

Important: master is tracking with ScaleIO 2.0 and up, for ScaleIO 1.3x use tag v1.3 of this repository, no further development on the 1.3x version of ScaleIO will be performed.

## Installation

To install ansible-scaleio just clone the repo and see site.yml as a generic playbook. If you are using Vagrant you can actually use the Vagrantfile in the appropriate tests folder to launch an environment to play with.

## Requirements

- Hosts should be bootstrapped for ansible usage (have python,...)
- Root privileges, eg `become: yes`

## Role Variables

 Some required variables are set in `site.yml` so please check then out, they mainly relates to your network setup and
 node naming.


 | Variable | Description | Default value |
 |----------|-------------|---------------|
 | `scaleio_mdm_primary_ip` | Primary MDM IP addresses (can be comma separated)| `{{ hostvars[groups['mdm'][0]]['ansible_'+scaleio_interface]['ipv4']['address'] }}"` |
 | `scaleio_mdm_primary_hostname`| Primary MDM hostname | `"{{ hostvars[groups['mdm'][0]]['inventory_hostname'] }}"` |
 | `scaleio_mdm_secondary_ip` | Secondary MDM IP addresses (can be comma separated)| `{{ hostvars[groups['mdm'][1]]['ansible_'+scaleio_interface]['ipv4']['address'] }}"` |
 | `scaleio_mdm_secondary_hostname`| Secondary MDM hostname | `"{{ hostvars[groups['mdm'][1]]['inventory_hostname'] }}"` |
 | `scaleio_mdm_tertiary_ip` | Tertiary MDM IP addresses (can be comma separated), if 5_node mode| `{{ hostvars[groups['mdm'][2]]['ansible_'+scaleio_interface]['ipv4']['address'] }}"` |
 | `scaleio_mdm_tertiary_hostname`| Tertiary MDM hostname | `"{{ hostvars[groups['mdm'][2]]['inventory_hostname'] }}"` |
 | `scaleio_tb_primary_ip` | Primary TB IP addresses (can be comma separated)| `{{ hostvars[groups['tb'][0]]['ansible_'+scaleio_interface]['ipv4']['address'] }}"` |
 | `scaleio_tb_primary_hostname`| Primary TB hostname | `"{{ hostvars[groups['tb'][0]]['inventory_hostname'] }}"` |
 | `scaleio_tb_secondary_ip` | Secondary TB IP addresses (can be comma separated), if 5_node mode| `{{ hostvars[groups['tb'][1]]['ansible_'+scaleio_interface]['ipv4']['address'] }}"` |
 | `scaleio_tb_secondary_hostname`| Secondary TB hostname | `"{{ hostvars[groups['tb'][1]]['inventory_hostname'] }}"` |
 | `scaleio_mdm_ips`| List of MDM IP's, depends on 3_node or 5_node mode | `"{{ scaleio_mdm_secondary_ip }},{{scaleio_mdm_primary_ip}}"` or `{{ scaleio_mdm_secondary_ip }},{{scaleio_mdm_primary_ip}},{{scaleio_mdm_tertiary_ip}` |

 The variables below are defined in the `group_vars/all` file but could be specified in other YAML file and load at
 run time.

| Variable | Description | Default value |
|----------|-------------|---------------|
| `scaleio_license` | Not in use currently | `` |
| `scaleio_protection_domain` | Protection domain name |  `protection_domain1` |
| `scaleio_cluster_name` | Cluster name |  `cluster1` |
| `scaleio_storage_pool` | Storage pool name |  `pool1` |
| `scaleio_cluster_mode` | Cluster mode, can be 3_node or 5_node |  `"5_node"` |
| `scaleio_interface` | Interface for ScaleIO, used if you do use site.yml |  `eth1` |
| `scaleio_password` | Password for the admin user |  `Cluster1!` |
| `scaleio_common_file_install_file_location` | Where are the files that will need to be installed |  `../files` |
| `scaleio_gateway_admin_password` | Admin password for the gateway |  `'Cluster1!'` |
| `scaleio_gateway_is_redundant` | Is the gateway redundant (will install keepalived) |  `'false'` |
| `scaleio_gateway_virtual_ip` | Virtual IP if redundant `` | '' |
| `scaleio_gateway_virtual_interface` | Interface to attach the virtual ip | 'eth1' |
| `scaleio_lia_token` | Lia password for node management |  `'Cluster1!'` |
| `scaleio_lia_conf_file` | Lia configuration file to set the password |  `'/opt/emc/scaleio/lia/cfg/conf.txt'` |
| `scaleio_sdc_driver_sync_repo_address` | Repository address for the kernel modules |  `'ftp://ftp.emc.com/'` |
| `scaleio_sdc_driver_sync_repo_user` | Username for the repository |  `'QNzgdxXix'` |
| `scaleio_sdc_driver_sync_repo_password` | Password for the repository |  `'Aw3wFAwAq3'` |
| `scaleio_sdc_driver_sync_repo_local_dir` | Local cache of the repository |  `'/bin/emc/scaleio/scini_sync/driver_cache/'` |
| `scaleio_sdc_driver_sync_user_private_rsa_key_src` | Private ssh rsa key source (if using sftp protocol)|  `''` |
| `scaleio_sdc_driver_sync_user_private_rsa_key_dest` | Private ssh rsa key destination |  `'/bin/emc/scaleio/scini_sync/scini_key'` |
| `#scaleio_sdc_driver_sync_repo_public_rsa_key_src` | Public ssh rsa key source (if using sftp protocol)|  `''` |
| `scaleio_sdc_driver_sync_repo_public_rsa_key_dest` | Private ssh rsa key destination |  `'/bin/emc/scaleio/scini_sync/scini_repo_key.pub'` |
| `scaleio_sdc_driver_sync_module_sigcheck` | Do we check the signature |  `1` |
| `scaleio_sdc_driver_sync_emc_public_gpg_key_src` | Where is the signature file |  `"{{ scaleio_common_file_install_file_location }}/files/RPM-GPG-KEY-ScaleIO_2.0.6035.0"` |
| `scaleio_sdc_driver_sync_emc_public_gpg_key_dest` | Where to put the signature file |  `'/bin/emc/scaleio/scini_sync/emc_key.pub'` |
| `scaleio_sdc_driver_sync_sync_pattern` | Repo sync pattern |  `.*` |
| `scaleio_sds_number` | Number of SDS to run on the sds's |  `1` |
| `scaleio_sds_disks` | Disk to use, if this variable is not defined, the system will use `roles/sds/library/disk_facts.py`|  `{ ansible_available_disks: ['/home/vagrant/scaleio1']   }` |
| `scaleio_skip_java` | Skip Java installation for ScaleIO (assume it's on the system) | `false` |

## Usage Instructions

Customize the roles and playbooks to your environment, you can use this to either to install ScaleIO or just enable the different modules on the nodes.

```
  ansible-playbook -i hosts site.yml
```

## Future

- Extend to do more special setup with cache
- Clean up the code (always more cleanup)
- Upgrade between ScaleIO releases.

## Authors

ansible-scaleio was created by [Sebastien Perreault](https://github.com/sperreault/) and is in part sponsored by [EMC](http://www.emc.com/)

## Contribution

Create a fork of the project into your own repository. Make all your necessary changes and create a pull request with a description on what was added or removed and details explaining the changes in lines of code. If approved, project owners will merge it.

Licensing
---------
The MIT License (MIT)
Copyright (c) [2015], [EMC Corporation)]
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Support
-------
Please file bugs and issues at the Github issues page. For more general discussions you can contact the EMC Code team at <a href="https://groups.google.com/forum/#!forum/emccode-users">Google Groups</a> or tagged with **EMC** on <a href="https://stackoverflow.com">Stackoverflow.com</a>. The code and documentation are released with no warranties or SLAs and are intended to be supported through a community driven process.
===============
