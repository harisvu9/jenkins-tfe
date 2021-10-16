#!/bin/bash

echo "Initializing Jenkins instance" >> /tmp/instance.txt

echo "Waiting for Terraform to copy files to instance"

sleep 120

export DISTRO=bionic
export DEBIAN_FRONTEND=noninteractive

apt-get update -y --fix-missing
apt-get upgrade -y --fix-missing

apt-get install -y --no-install-recommends openjdk-8-jdk

apt-get install -y --no-install-recommends \
    software-properties-common \
    apt-transport-https \
    curl \
    git \
    tzdata \
    libcurl4-openssl-dev \
    libssl-dev \
    lsb-release \
    ca-certificates \
    python3 \
    python3-distutils \
    python3-setuptools \
    gnupg2 \
    jq \
    zip \
    unzip \
    sudo \
    wget \
    file

# Switch to Python 3 as default and install pip, awscli and boto3
update-alternatives --install /usr/bin/python python /usr/bin/python2 1
update-alternatives --install /usr/bin/python python /usr/bin/python3 2
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py
pip install awscli
pip install boto3
pip install jinja2 ldap3
rm -rf get-pip.py

# Ansible
apt-add-repository --yes --update ppa:ansible/ansible

# Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

# AWS IAM Authenticator
curl -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
chmod +x /usr/bin/aws-iam-authenticator

# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y  jenkins
systemctl enable jenkins
sleep 60
cat /var/lib/jenkins/secrets/initialAdminPassword


# Terraform
curl -o terraform_0.11.13_linux_amd64.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm -rf terraform*

# Helm
curl -o helm-v2.13.0-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz
tar -zxvf helm-v2.13.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64/
rm -rf helm*

# Install all the apt packages
apt-get update -y --fix-missing
apt-get install -y --fix-missing ansible kubectl docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker


echo "Completed Initializing Jenkins instance" >> /tmp/instance.txt
