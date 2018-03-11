# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'fileutils'

config = {
    local: "./vagrant/settings/local.yml",
    example: "./vagrant/settings/example.yml"
}

# copy config from example if local config not exists
FileUtils.cp config[:example], config[:local] unless File.exist?(config[:local])
# read config
options = YAML.load_file config[:local]

ENV["LC_ALL"] = "en_US.UTF-8"
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define options["machine_name"]
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.vm.box = "ubuntu/xenial64"
    config.vm.hostname = options["hostname"]
    config.vm.network "private_network", ip: options["ip"]
    config.vm.synced_folder ".", "/home/dsearch", owner: "www-data", group: "www-data"
    config.vm.network "forwarded_port", guest: 80, host: 80
    config.vm.provision :hostmanager

    config.hostmanager.enabled            = true
    config.hostmanager.manage_host        = true
    config.hostmanager.ignore_private_ip  = false
    config.hostmanager.include_offline    = true
    config.hostmanager.aliases            = options["domains"].values
    
    config.vm.provider "virtualbox" do |vm|
        vm.name = options["machine_name"]
        vm.customize ["modifyvm", :id, "--name", options["machine_name"]]
        vm.customize ["modifyvm", :id, "--memory", options["memory"]]
        vm.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]  
        vm.customize ['modifyvm', :id, '--acpi', 'on']
        vm.customize ['modifyvm', :id, '--cpus', options["cpus"] ]
        vm.customize ['modifyvm', :id, '--cpuexecutioncap', '100']
        vm.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vm.customize ['modifyvm', :id, '--natdnsproxy1', 'on']  
    end

    config.trigger.after :destroy do
        if File.exist?('./vagrant/.provision')
            FileUtils.rm('./vagrant/.provision') 
        end
    end
  
    config.vm.provision:shell, :path => "vagrant/provision/bootstrap.sh", env: {
        :INSTALL_JAVA8 => options["installJava8"],
        :INSTALL_NEO4J => options["installNeo4j"]
    }

    config.vm.provision:shell, :path => "vagrant/provision/always-as-root.sh", run: "always", env: {
        :INSTALL_JAVA8 => options["installJava8"],
        :INSTALL_NEO4J => options["installNeo4j"]
    }
    config.vm.provision:shell, :path => "vagrant/provision/always-as-vagrant.sh", run: "always", privileged: false, env: {
        :INSTALL_JAVA8 => options["installJava8"],
        :INSTALL_NEO4J => options["installNeo4j"]
    }

    config.vm.post_up_message = "successfull boot ! welcome."
end