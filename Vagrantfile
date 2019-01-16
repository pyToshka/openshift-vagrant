# -*- mode: ruby -*-
# vi: set ft=ruby :
#
cpu = 4
mem = 8192
project = 'okd'
N = 1
REQUIRED_PLUGINS = %w(vagrant-hostmanager)
errors = []
def message(name)
    "#{name} plugin is not installed, run `vagrant plugin install #{name}` to install it."
end
REQUIRED_PLUGINS.each { |plugin| errors << message(plugin) unless Vagrant.has_plugin?(plugin) }
unless errors.empty?
    msg = errors.size > 1 ? "Errors: \n* #{errors.join("\n* ")}" : "Error: #{errors.first}"
    fail Vagrant::Errors::VagrantError.new, msg
end

Vagrant.configure(2) do |config|
  #
  # vm specs
  #
  config.vm.provider "virtualbox" do |v|
    v.memory = mem
    v.cpus = cpu
  end

  #
  # Use insecure key
  config.ssh.insert_key = false
  #

  #
  # Configre private_ip as hostname
  #
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  #
  # Create master nodes
  #
  (1..N).each do | node_nr |
    hostname = project + "-master#{node_nr}"
    random_ssh_port = (30000..65534).to_a.sample
    random_http_port = (30000..65534).to_a.sample
    random_https_port = (30000..65534).to_a.sample

    config.vm.define hostname do | node |
      node.vm.box = 'centos/7'
      node.vm.hostname = hostname
      node.vm.network :forwarded_port, guest: 22, host: random_ssh_port, id: "ssh"
      node.vm.network :forwarded_port, guest: 80, host: random_http_port, id: "http"
      node.vm.network :forwarded_port, guest: 443, host: random_https_port, id: "https"
      node.vm.network "forwarded_port", guest: 8443, host: 8443
      node.vm.network "private_network", ip: "10.0.0.11#{node_nr}"

      #
      # Provision VMs using shell
      # Remove default Vagrant hostfile line, we want to use hostmanager
      #
      node.vm.provision :shell, inline: "sed -i'' '/^127.0.0.1\\t#{node.vm.hostname}\\t#{hostname}$/d' /etc/hosts"
      config.vm.provision "ansible_local" do |preinstall|
        preinstall.playbook = "/vagrant/ansible/clone.yml"
        preinstall.compatibility_mode = "2.0"
        preinstall.extra_vars = {
            machine_ip:"10.0.0.11#{node_nr}",
            master_route: hostname,
            openshift_ansible_version: 3.11
        }
      end

      config.vm.provision "ansible_local" do |prerequisites|
        prerequisites.provisioning_path = "/home/vagrant/openshift-ansible/playbooks/"
        prerequisites.compatibility_mode = "2.0"
        prerequisites.verbose = true
        prerequisites.raw_arguments = ['--limit=""']
        prerequisites.inventory_path = "/vagrant/ansible/inventory"
        prerequisites.playbook_command = "sudo ANSIBLE_FORCE_COLOR=true ansible-playbook"
        prerequisites.playbook = "prerequisites.yml"
        prerequisites.extra_vars = {
            machine_ip: "10.0.0.11#{node_nr}",
            master_route: hostname,
            openshift_ansible_version: 3.11
        }
      end

      config.vm.provision "ansible_local" do |deploy_cluster|
        deploy_cluster.provisioning_path = "/home/vagrant/openshift-ansible/playbooks/"
        deploy_cluster.compatibility_mode = "2.0"
        deploy_cluster.verbose = true
        deploy_cluster.raw_arguments = ['--limit=""']
        deploy_cluster.inventory_path = "/vagrant/ansible/inventory"
        deploy_cluster.playbook_command = "sudo ANSIBLE_FORCE_COLOR=true ansible-playbook"
        deploy_cluster.playbook = "deploy_cluster.yml"
        deploy_cluster.extra_vars = {
            machine_ip: "10.0.0.11#{node_nr}",
            master_route: hostname,
            openshift_ansible_version: 3.11
        }
      end

      config.vm.provision "ansible_local" do |postinstall|
        postinstall.playbook = "/vagrant/ansible/site.yml"
        postinstall.compatibility_mode = "2.0"
        postinstall.extra_vars = {
            machine_ip:"10.0.0.11#{node_nr}",
            master_route: hostname,
            openshift_ansible_version: 3.11
        }
      end

      config.trigger.after [:up, :reload, :provision] do |trigger|
        trigger.info = "OpenShift is ready!"
        trigger.run_remote = {
            inline: 'echo "Openshift is available at: https://$1.$2.nip.io:8443" with admin:admin',
            args: [hostname, "10.0.0.11#{node_nr}"]
        }
      end

      node.vm.provision :shell, inline: "oc adm policy add-cluster-role-to-user cluster-admin admin", privileged:true
    end
  end
end