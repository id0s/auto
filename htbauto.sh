tc qdisc add dev enp0s3 root handle 1: htb default 10
tc class add dev enp0s3 parent 1: classid 1:1 htb rate 1mbit ceil 1mbit
tc class add dev enp0s3 parent 1: classid 1:2 htb rate 500kbit ceil 1mbit
tc filter add dev enp0s3 protocol ip parent 1:0 prio 1 u32 match ip dport 80 0xffff flowid 1:1
tc filter add dev enp0s3 protocol ip parent 1:0 prio 1 u32 match ip dport 80 0xffff flowid 1:1
tc filter add dev enp0s3 protocol ip parent 1:0 prio 2 u32 match ip dport 21 0xffff flowid 1:2
