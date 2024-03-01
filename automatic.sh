#!/bin/bash

# Hapus file /etc/network/interfaces jika ada
apt install iproute2
ip link add dummy1 type dummy
ip addr add 192.168.1.10/255.255.255.0 dev dummy1
# Restart layanan networking

systemctl restart networking
apt update
apt install bind9 dnsutils -y


# Konfigurasi zona DNS reverse
echo 'zone "example.com"{
type master;
file "/etc/bind/db.example.com";
};


zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
};' > /etc/bind/named.conf.local

# Konfigurasi file zona DNS reverse (db.192.168.1)
echo '$TTL    604800
@       IN      SOA     ns.example.com. root.example.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      example.com.

; Define reverse DNS records
10      IN      PTR     example.com.
10      IN      PTR     example.com.
10      IN      PTR     192.168.1.10
' > /etc/bind/db.192.168.1

# Konfigurasi file zona DNS (db.example.com)
echo '$TTL    604800
@       IN      SOA     example.com. root.example.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      example.com.

; Define DNS records
@       IN      A           192.168.1.10
www     IN      CNAME       example.com
mail    IN      CNAME       example.com
' > /etc/bind/db.example.com


# Restart BIND9 service
systemctl restart bind9
echo 'nameserver 192.168.1.10 
search example.com'> /etc/resolv.conf

#meginstall monitorix
chmod +x monitorix.sh
./monitorix.sh
#menginstall haproxy
apt install haproxy
cp haproxy.cfg /etc/haproxy
systemctl restart haproxy
systemctl restart monitorix


#install webmin
cd /home/dos/auto/webmin
chmod +x setup.sh
./setup.sh

echo "ip address berhasil dikonfigurasi,konfigurasi dns bind9 sudah berhasil,resolv berhasil dikonfigurasi "
systemctl restart bind9

