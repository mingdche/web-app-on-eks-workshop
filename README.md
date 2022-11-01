# Terraform VPC Networking
The library includes a terraform design for provisioning AWS VPC networking.

### 安装相关软件
git clone https://github.com/mingdche/web-app-on-eks-workshop 

cd web-app-on-eks-workshop

./init.sh

```
cat > terraform.tfvars <<EOF
//AWS 
region      = "ap-southeast-1"
environment = "k8s"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] //List of Public subnet cidr range
private_subnets_cidr = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"] //List of private subnet cidr range
EOF
```

```
terraform init
terraform plan
terraform apply
```