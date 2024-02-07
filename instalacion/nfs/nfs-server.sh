#!/bin/bash
sudo apt install nfs-kernel-server -y
sudo mkdir -p /home/ubuntu/environment/volumenes/nfs
sudo chown nobody:nogroup /home/ubuntu/environment/volumenes/nfs/
sudo chmod 777 /home/ubuntu/environment/volumenes/nfs/
echo "/home/ubuntu/environment/volumenes/nfs 172.0.0.0/8(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports > /dev/null
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo ufw allow from 0.0.0.0/0 to any port nfs
showmount -e 