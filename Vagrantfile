# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
require File.dirname(__FILE__)+"/setup/provision/dependency_manager"

CONF = YAML.load(File.open(File.join(File.dirname(__FILE__), "config.yaml"), File::RDONLY).read)

Vagrant.configure("2") do |config|
    check_plugins ["vagrant-vbguest", "vagrant-hostmanager"]

    if Vagrant::Util::Platform.windows? then
      check_plugins ["vagrant-winnfsd"]
    end

    config.vm.hostname = CONF['vm_hostname']
    config.hostmanager.aliases = Array.new

    config.vbguest.auto_update = false
    
    config.ssh.username = CONF['ssh_username'] || "vagrant"
    config.ssh.password = CONF['ssh_password'] || "vagrant"

    # Add each site to our hostmanager aliases, appending the
    # vm's hostname.
    CONF['sites'].each do |site|
      config.hostmanager.aliases.push site['name'] + "." + config.vm.hostname
    end

    # This tells VirtualBox to let our VM use the host DNS.
    # (you probably won't have access to the external internet from
    #  the VM without this).
    # @TODO Add support for other providers (i.e, VMWare)
    config.vm.provider :virtualbox do |vb|
      vb.cpus = CONF['vm_cpu']
      vb.memory = CONF['vm_memory']
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ['modifyvm', :id, '--ioapic', 'on']
    end

    config.vm.box = "bento/ubuntu-20.04"
    config.vm.network "private_network", ip: CONF['vm_ip']
    config.vm.network :forwarded_port, guest: 3306, host: 3306, host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 3000, host: 3000, host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 5432, host: 5432, host_ip: "127.0.0.1" #PostGres
    config.vm.network :forwarded_port, guest: 6379, host: 6379, host_ip: "127.0.0.1" #Redis
    config.vm.network :forwarded_port, guest: 27017, host: 27017, host_ip: "127.0.0.1" #MongoDB
    config.vm.network :forwarded_port, guest: 8080, host: 8080,  host_ip: "127.0.0.1" # RethinkDB Web UI
    config.vm.network :forwarded_port, guest: 28015, host: 28015,  host_ip: "127.0.0.1" # Client driver
    config.vm.network :forwarded_port, guest: 29015, host: 29015, host_ip: "127.0.0.1" # Intracluster traffic

    config.vm.synced_folder CONF['vm_code'], "/var/www/vhosts", mount_options: ["dmode=777,fmode=777"]

    config.hostmanager.enabled = true
    if Vagrant::Util::Platform.windows? then
      config.hostmanager.manage_host = false
    else
      config.hostmanager.manage_host = true
    end

        
    # Format the domains as a comma-separated list
    # to pass into the shell script.
    vhosts = '"' + config.hostmanager.aliases.join(",") + '"';

    config.vm.provision "shell", path: "setup/provision/mysql.sh"
    config.vm.provision "shell", path: "setup/provision/core.sh"

    config.vm.provision "shell", run: "always" do |s|
      s.args = vhosts + " " + CONF['vm_ip'] + " " + config.vm.hostname
      s.path = "setup/provision/domains.sh"
    end 

    config.vm.provision "shell", path: "setup/provision/final.sh"

    # This is a temporary hack to address sites not loading after the
    # host machine sleeps or is halted and started back up.
    # @TODO Isolate and address the underlying problem here.
    config.vm.provision "shell", inline: "sudo service apache2 restart", run: "always"
    config.vm.provision "shell", inline: "sudo composer self-update", run: "always"
    config.vm.provision "shell", inline: "sudo service mysql restart", run: "always"

    # Hosts file management
    if Vagrant.has_plugin?("vagrant-hostmanager")
      config.vm.provision :hostmanager
    end

    # BACKUP MYSQL DATABASES
    config.trigger.before :destroy do |trigger|
      trigger.warn = "Dumping databases to CONF['vm_code']"
      trigger.run_remote = {inline: "cd /var/www/vhosts && bash dbbackup.sh"}
      trigger.on_error = :continue
    end
end
