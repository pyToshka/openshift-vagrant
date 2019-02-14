# openshift-vagrant


This project aims to provision a CentOS 7 with OKD all-in-one, using openshift-ansible with container storage, router, registry, metrics, logging and etc.</br>

You can change in environment varibles Vagrantfile file or use os environment varibles. It defaults to origin, v3.11 and 10.0.0.111 respectively.</br>

After vagrant up you'll be able to access your OpenShift instance at: [https://okd.master1.10.0.0.111.nip.io:8443](https://okd.master1.10.0.0.111.nip.io:8443/) with  ```admin:admin```. </br>

## Brokers

### List of work brokers
 * [Ansible Service Brocker](https://developers.redhat.com/blog/2018/05/23/customizing-an-openshift-ansible-playbook-bundle/)
 * [Service Catalog](https://docs.openshift.com/container-platform/3.11/architecture/service_catalog/index.html)

### CLI for work with them
 * [svcat](https://svc-cat.io/)
 * [apb](http://automationbroker.io/)

## Switch container runtime

For switching container runtime you need change this setting to `False` in __OSEv3.yml__ (folder __group_vars__):
```
openshift_use_crio: true
openshift_use_crio_only: true
```

Then in __inventory__ file (folder __ansible__) change node group to `node-config-all-in-one` for `okd-master1`:
```
okd-master1 openshift_node_group_name=node-config-all-in-one-crio ansible_connection=local
```

## Hostname of VM

Hostname defines here:
```
hostname = project + "-master#{node_nr}"
```

## Backup script

In folder `templates` there is script `backupimage.sh` which can re-tag images and push to your registry.

## Openshift variables

All variables in vars file located in `group_vars` in file `OSEv3.yml`. Enjoy :) (For comments thanks to [Asgoret](https://github.com/Asgoret))

## Vagrant variables

All vagrant variables located in `Vagrantfile`. Enjoy :)

## Vagrant DNS

If you want to add Vagrant DNS use this plugin: [Vagrant DNS](https://github.com/BerlinVagrant/vagrant-dns)
And some examples:
* Vagrantfile:
```
#
# Create dnsmasq
#
config.dns.tld = "okd-vagrant.domain.com"
config.vm.hostname = "apps"
config.dns.patterns = [/^.*apps.okd-vagrant.domain.com$/]
```
* Vagrantfile (part __deploy_cluster__):
```
deploy_cluster.extra_vars = {
...
    dns_name: "#{hostname}"
```
* __OSEv3.yml__:
```
# OKD URLs
openshift_master_cluster_hostname: "{{ dns_name }}"
openshift_master_cluster_public_hostname: "okd-vagrant.domain.com"
openshift_master_default_subdomain: "apps.okd-vagrant.domain.com"
```

## LDAP
LDAP configuratine in vars file located in `group_vars` in file `OSEv3.yml`.

## Dependency

 - Vagrant
 - vagrant-hostmanager plugin
 - VirtualBox

## Limitations

 - Tested only on MacOS, Suse
 - Only tested with VirtualBox

## Updates:

 - Cri-O support many thanks to [Asgoret](https://github.com/Asgoret)
 - Testing on Linux Suse many thanks to [gecube](https://github.com/gecube)
