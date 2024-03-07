#!/bin/bash

read -p "Enter Proxmox Node IP: " PROXMOX_NODE_IP
read -p "Enter Proxmox Node Name: " PROXMOX_NODE_NAME
read -p "Enter Proxmox Storage: " PROXMOX_STORAGE
read -p "Enter API User: " API_USER
read -s -p "Enter API User Password: " API_USER_PASSWORD
echo

CRED="username=$API_USER@pve&password=$API_USER_PASSWORD"

curl --silent --insecure --data $CRED https://$PROXMOX_NODE_IP:8006/api2/json/access/ticket | jq --raw-output '.data.ticket' | sed 's/^/PVEAuthCookie=/' > cookie
curl --silent --insecure --data $CRED https://$PROXMOX_NODE_IP:8006/api2/json/access/ticket | jq --raw-output '.data.CSRFPreventionToken' | sed 's/^/CSRFPreventionToken:/' > token

# Container configuration
CPU=1
CPUUNITS=512
MEMORY=512
DISK=4G
SWAP=0
OS_TEMPLATE="IMAGES:vztmpl/centos-8-default_20191016_amd64.tar.xz"

# Script options
case $1 in
    start|stop) curl --silent --insecure --cookie "$(<cookie)" --header "$(<token)" -X POST https://$PROXMOX_NODE_IP:8006/api2/json/nodes/$PROXMOX_NODE_NAME/lxc/$2/status/$1; echo "  done." ;;
    create) 
        read -p "Enter VMID: " VMID
        curl --insecure  --cookie "$(<cookie)" --header "$(<token)" -X POST --data-urlencode net0="name=tnet$VMID,bridge=vmbr0" --data ostemplate=$OS_TEMPLATE --data storage=$PROXMOX_STORAGE --data vmid=$VMID --data cores=$CPU --data cpuunits=$CPUUNITS --data memory=$MEMORY --data swap=$SWAP --data hostname=ctnode$VMID https://$PROXMOX_NODE_IP:8006/api2/json/nodes/$PROXMOX_NODE_NAME/lxc; echo "  done." ;;
    delete) 
        read -p "Enter VMID to delete: " VMID
        curl --silent --insecure --cookie "$(<cookie)" --header "$(<token)" -X DELETE https://$PROXMOX_NODE_IP:8006/api2/json/nodes/$PROXMOX_NODE_NAME/lxc/$VMID; echo "  done." ;;
    *) 
        echo ""
        echo " Usage: start|stop|create|delete <vmid>"
        echo "" ;;
esac

# Remove cookie and token
rm cookie token
