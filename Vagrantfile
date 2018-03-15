# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"

CONF = YAML.load(File.open(File.join(File.dirname(__FILE__), "config.yaml"), File::RDONLY).read)

Vagrant.configure("2") do |config|

    config.vm.hostname = CONF['vm_hostname']
    config.hostmanager.aliases = Array.new

    config.vbguest.auto_update = true
    
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

    config.vm.box = "scotch/box-pro"
    config.vm.network "private_network", ip: CONF['vm_ip']
    config.vm.network :forwarded_port, guest: 3306, host: 3306, host_ip: "127.0.0.1"
    
    config.vm.synced_folder CONF['vm_code'], "/var/www/vhosts", :nfs => { :mount_options => ["dmode=777","fmode=666"] }
    config.vm.synced_folder CONF['vm_data'], "/var/lib/mysql/", id: "mysql", owner: "mysql", group: "mysql", mount_options: ["dmode=775,fmode=664"]
    
    config.hostmanager.enabled = true
    if Vagrant::Util::Platform.windows? then
      config.hostmanager.manage_host = false
    else
      config.hostmanager.manage_host = true
    end

        
    # Format the domains as a comma-separated list
    # to pass into the shell script.
    vhosts = '"' + config.hostmanager.aliases.join(",") + '"';

    config.vm.provision "shell" do |s|
      s.args = vhosts + " " + CONF['vm_ip'] + " " + config.vm.hostname
      s.path = "setup/provision/setup.sh"
                
    end

    # This is a temporary hack to address sites not loading after the
    # host machine sleeps or is halted and started back up.
    # @TODO Isolate and address the underlying problem here.
    config.vm.provision "shell", inline: "sudo service apache2 restart", run: "always"
    config.vm.provision "shell", inline: "sudo composer self-update", run: "always"
end
