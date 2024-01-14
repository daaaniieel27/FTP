### Archivos de configuración Servidor FTP (Anonymous)
**.message**
```
  __       __  ________  __        ______    ______   __       __  ________ 
|  \  _  |  \|        \|  \      /      \  /      \ |  \     /  \|        \
| $$ / \ | $$| $$$$$$$$| $$     |  $$$$$$\|  $$$$$$\| $$\   /  $$| $$$$$$$$
| $$/  $\| $$| $$__    | $$     | $$   \$$| $$  | $$| $$$\ /  $$$| $$__    
| $$  $$$\ $$| $$  \   | $$     | $$      | $$  | $$| $$$$\  $$$$| $$  \   
| $$ $$\$$\$$| $$$$$   | $$     | $$   __ | $$  | $$| $$\$$ $$ $$| $$$$$   
| $$$$  \$$$$| $$_____ | $$_____| $$__/  \| $$__/ $$| $$ \$$$| $$| $$_____ 
| $$$    \$$$| $$     \| $$     \\$$    $$ \$$    $$| $$  \$ | $$| $$     \
 \$$      \$$ \$$$$$$$$ \$$$$$$$$ \$$$$$$   \$$$$$$  \$$      \$$ \$$$$$$$$



```
**resolv.conf**

Configuración del sistema para la resolución de nombres.
```
nameserver 192.168.57.10
```
**vsftpd.conf**

Configuración principal del servidor FTP anónimo.
```
listen=YES
listen_ipv6=NO
listen_address=192.168.57.30
pam_service_name=vsftpd
use_localtime=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
anonymous_enable=YES
local_enable=NO
write_enable=NO
no_anon_password=YES
data_connection_timeout=30
anon_max_rate=5000
ftpd_banner=Welcome to SRI FTP anonymous server
dirmessage_enable=YES
```


### Archivos de configuración Servidor FTP (Usuarios locales)
**vsftpd.conf**

Configuración principal del servidor FTP para usuarios locales.
```
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
chroot_local_user=NO
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
force_local_logins_ssl=YES
force_local_data_ssl=YES
ftpd_banner=Welcome to SRI FTP server
rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
ssl_enable=YES
```
**resolv.conf**

Configuración del sistema para la resolución de nombres.
```
nameserver 192.168.57.10
```
**vsftpd_chroot_list**

Lista de usuarios permitidos para chroot.
```
charles
```


### Archivos de configuración Servidor DNS
**named.conf.local**

Configuración de las zonas locales del servidor DNS.
```
zone "db.sri" {
        type master;
        file "/var/lib/bind/db.sri.dns";
};

zone "57.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/db.sri.rev";
};

```
**named.conf.options**

Opciones de configuración global del servidor DNS.
```
options {
        directory "/var/cache/bind";

        
        forwarders {
              1.1.1.1;
        };

        dnssec-validation yes;

        listen-on-v6 { any; };
};

```
**db.sri.dns**

Zona directa del servidor DNS.
```
;
; Zone file for db.sri
;

$TTL    604800
@       IN      SOA     ns.db.sri admin.ns.db.sri (
			      1		; Serial
			 604800		; Refresh
			    300		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL

; 
@       IN      NS      ns

; 
ns.db.sri.	IN	A	192.168.57.10
mirror.db.sri.	IN  	A       192.168.57.30
ftp.db.sri.	IN  	A       192.168.57.20
```
**db.sri.rev**

Zona inversa del servidor DNS.
```
;
; Reverse zone file for db.sri
;

$TTL	86400
@	IN	SOA	ns.db.sri. admin.db.sri. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  7200 )	; Negative Cache TTL
;

@		IN	NS	ns.db.sri.
10		IN	PTR	ns.db.sri.
20		IN	PTR	ftp.db.sri.
30		IN	PTR	mirror.db.sri.
```




# Provision files

### FTP Server (Anonymous)
```
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
```

### FTP Server (Local Users)
```
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

```

### DNS Server
```
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

```
