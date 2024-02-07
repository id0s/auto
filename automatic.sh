#!/bin/bash

# Hapus file /etc/network/interfaces jika ada
rm -f /etc/network/interfaces

# Buat file baru /etc/network/interfaces dengan konfigurasi default
echo 'auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 192.168.1.10
    netmask 255.255.255.0' > /etc/network/interfaces

# Restart layanan networking

systemctl restart networking

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

./monitorix.sh
cp haproxy.cfg /etc/haproxy

clear


echo "ip address berhasil dikonfigurasi,konfigurasi dns bind9 sudah berhasil,resolv berhasil dikonfigurasi "
systemctl restart bind9

