#!/bin/sh

# Install jq (json query)
sudo yum -y -q install jq

# Install awscli v2
curl -O "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q -o awscli-exe-linux-x86_64.zip
sudo ./aws/install
rm awscli-exe-linux-x86_64.zip
whereis aws

# Install kubectl
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
echo "source <(kubectl completion bash)" >> ~/.bashrc
whereis kubectl

# Install eksctl and move to path
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
whereis eksctl

# Install helm
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Set up environment variables

AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export AWS_DEFAULT_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile

INSTANCE_ID=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)
echo "export INSTANCE_ID=${INSTANCE_ID}" | tee -a ~/.bash_profile

# Set up instance profile to bypass Cloud9 restriction
aws ec2 associate-iam-instance-profile --iam-instance-profile Name=TeamRoleInstanceProfile --instance-id=${INSTANCE_ID}
aws cloud9 update-environment  --environment-id $C9_PID --managed-credentials-action DISABLE
rm ~/.aws/credentials
aws sts get-caller-identity

aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
