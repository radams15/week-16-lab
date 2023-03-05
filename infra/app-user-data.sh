#!/bin/bash
# This script is injected into the AWS vm on creation
# and can be used to provision your VM
# NB it's run as root, so no need for sudo

# debug logs are here
readonly logName="/var/log/server-setup.log"

echo "Starting $(date)" | tee -a "${logName}"

echo "Install required tools" | tee -a "${logName}"
yum install -y docker vim curl

# put your own github username here
echo "Setting up ssh access keys" | tee -a "${logName}"
curl -s https://github.com/radams15.keys | tee -a /home/ec2-user/.ssh/authorized_keys

usermod -aG docker ec2-user

# running docker daemon as a service
systemctl enable --now docker

# Allow docker to bind to port 80
sysctl -w net.ipv4.ip_unprivileged_port_start=80


# Run docker container as ec2-user
sudo -u ec2-user docker run -d -p 80:8080 --rm docker.io/radams15/aaf-internal-notes-system
