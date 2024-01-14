#!/bin/bash
export DEBIAN_FRONTERED=noninteractive

# Actualizamoz e instalamos ftp
sudo apt-get update
sudo apt-get install -y vsftpd

# Creamos los usuarios
sudo useradd -m -p 1234 charles
sudo useradd -m -p 1234 laura

sudo apt-get remove --purge vsftpd
sudo apt-get install vsftpd

sudo apt-get update

# Creamos las claves y los certificados SSL necesarios
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/etc/ssl/private/vsftpd.key" -out "/etc/ssl/certs/vsftpd.crt" -subj "/O=Usuario/CN=Usuario" -passout "pass:Admin1.@"

sudo cp /vagrant/files/ftp/resolv.conf /etc/

sudo systemctl restart vsftpd

sudo cp /vagrant/files/ftp/vsftpd.chroot_list /etc/

sudo systemctl restart vsftpd

sudo cp /vagrant/files/ftp/vsftpd.conf /etc/

sudo systemctl restart vsftpd

# Corrige los errores de espacios en /etc/vsftpd.conf
sudo sed -i 's,\r,,;s, *$,,' /etc/vsftpd.conf

# Reiniciar el servicio vsftpd
sudo service vsftpd restart

unset DEBIAN_FRONTERED
