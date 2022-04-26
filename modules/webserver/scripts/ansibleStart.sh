#!/bin/bash
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo chmod 600 /home/ubuntu/.ssh/Estio-Ubuntu.pem
cd /home/ubuntu/
ansible-playbook -v -i inventory.yml playbook.yml


