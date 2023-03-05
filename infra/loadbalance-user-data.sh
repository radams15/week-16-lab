#!/bin/bash
# This script is injected into the AWS vm on creation
# and can be used to provision your VM
# NB it's run as root, so no need for sudo

# debug logs are here

readonly APP_IP='10.0.1.20'

readonly logName="/var/log/server-setup.log"

echo "Starting $(date)" | tee -a "${logName}"

echo "Install required tools" | tee -a "${logName}"

amazon-linux-extras install nginx1 -y

yum install -y curl


# put your own github username here
echo "Setting up ssh access keys" | tee -a "${logName}"
curl -s https://github.com/radams15.keys | tee -a /home/ec2-user/.ssh/authorized_keys

echo "Setting up nginx" | tee -a "${logName}"

systemctl stop nginx

cat <<EOF >/etc/nginx/nginx.conf
events {

}

http {
	server {
		listen 80;

		location / {
			proxy_pass http://${APP_IP}:80;
		}
	}
}
EOF


systemctl enable --now nginx
