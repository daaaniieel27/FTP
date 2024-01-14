#!/bin/bash

export DEBIAN_FRONTERED=noninteractive

apt-get -y update
apt-get -y upgrade

#Instalamos el servicio bind9 para configurar el servidor DNS

sudo apt-get -y update
sudo apt-get -y install bind9

cp /vagrant/files/named.conf.options /etc/bind/
cp /vagrant/files/named.conf.local /etc/bind/
cp /vagrant/files/db.sri.dns /var/lib/bind/
cp /vagrant/files/db.sri.rev /var/lib/bind/
cp /vagrant/files/resolv.conf /etc/resolv.conf

sudo systemctl restart bind9

unset DEBIAN_FRONTERED
