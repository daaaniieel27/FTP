# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    #Obligatoria
    config.vm.box = "debian/bullseye64"

    #Configuraciones básicas de las MVs
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "256" #RAM
      vb.linked_clone = true 
    end #provider

    #Creamos una máquina llamada debian

    config.vm.define "DNS" do |debian|
        debian.vm.hostname = "DNS"
        debian.vm.network :public_network
        debian.vm.network :private_network, ip: "192.168.57.10"
       debian.vm.provision "shell", path: "provision1.sh"
      end

    config.vm.define "FTP" do |debian|
      debian.vm.hostname = "FTP"
      debian.vm.network :public_network
      debian.vm.network :private_network, ip: "192.168.57.20"
     debian.vm.provision "shell", path: "provision2.sh"
    end

    config.vm.define "AnonymousFTP" do |debian|
        debian.vm.hostname = "AnonymousFTP"
        debian.vm.network :public_network
        debian.vm.network :private_network, ip: "192.168.57.30"
        debian.vm.provision "shell", path: "provision3.sh"
       end
       
  end