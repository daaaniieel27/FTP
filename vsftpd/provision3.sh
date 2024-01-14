#!/bin/bash

export DEBIAN_FRONTERED=noninteractive

apt-get -y update
apt-get -y upgrade


# Instalamos el servicio ftp
sudo apt -y install vsftpd

cp /vagrant/files/anonymous/vsftpd.conf /etc/vsftpd.conf 
cp /vagrant/files/anonymous/.message /srv/ftp/

sudo sed -i 's,\r,,;s, *$,,' /etc/vsftpd.conf

sudo systemctl restart vsftpd.service

cp /vagrant/files/anonymous/resolv.conf /etc/resolv.conf

unset DEBIAN_FRONTERED