#!/bin/bash
# This script is injected into the AWS vm on creation
# and can be used to provision your VM
# NB it's run as root, so no need for sudo

# debug logs are here
readonly logName="/var/log/server-setup.log"

echo "Starting $(date)" | tee -a "${logName}"

echo "Install required tools" | tee -a "${logName}"
yum install -y \
    docker \
    iptraf-ng \
    htop \
    tmux \
    vim \
    curl \
    git

# put your own github username here
echo "Setting up ssh access keys" | tee -a "${logName}"
curl -s https://github.com/radams15.keys | tee -a /home/ec2-user/.ssh/authorized_keys

# add ec2 user to the docker group which allows docket to run without being a super-user
usermod -aG docker ec2-user

# running docker daemon as a service
chkconfig docker on
service docker start

echo "Creating rudimentary web page for debugging this VM" | tee -a "${logName}"
cat <<EOF >>/home/ec2-user/index.html
<html>
    <body>
        <h1>Welcome Warwick WM145 peeps</h1>
        <div>We hope you enjoy our debug page</div>
        <div id="image"><img src="https://placedog.net/500/280" /></div>
    </body>
</html>
EOF

echo "Starting a debug nginx web server on port 8080" | tee -a "${logName}"
docker run -d \
    --restart always \
    -v /home/ec2-user/index.html:/usr/share/nginx/html/index.html:ro \
    -p 8080:80 \
    nginx

############################################################
## 👇👇👇👇👇 application install commands here 👇👇👇👇👇

echo "installing Nodejs using NVM" | tee -a "${logName}"
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash -
yum -y install nodejs

echo "installing application" | tee -a "${logName}"
(cd /home/ec2-user && git clone https://github.com/radams15/week-16-lab.git)

echo "installing deps and starting application $(date)" | tee -a "${logName}"
(cd /home/ec2-user/week-16-lab/app && npm install && DEBUG=* PORT=80 npm start)
