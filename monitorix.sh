#!/bin/bash

# Pastikan script dijalankan sebagai root atau dengan akses sudo
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Instalasi paket-paket menggunakan apt-get
apt install -y rrdtool perl libwww-perl libmailtools-perl libmime-lite-perl librrds-perl libdbi-perl libxml-simple-perl libhttp-server-simple-perl libconfig-general-perl libio-socket-ssl-perl
dpkg -i monitorix.deb
# Periksa status keluaran apt-get
if [ $? -eq 0 ]; then
    echo "Instalasi berhasil"
else
    echo "Instalasi gagal. Silakan periksa log untuk informasi lebih lanjut."
fi
