# 将Web应用运行于EKS
本实验活动通过动手实践的方式帮助您了解EKS，在本次实验活动中您将体验到如下：
1. 通过terraform创建VPC
2. 通过terraform创建EKS集群
3. 配置EKS的监控和观测功能
4. 在EKS上部署简单的Web应用
5. 体验EKS的自动扩展功能
6. 通过FluentBit收集K8s日志以及应用日志

# 准备活动
### 安装相关软件
```bash
git clone https://github.com/mingdche/web-app-on-eks-workshop 

cd web-app-on-eks-workshop


./init.sh
```

以上命令为我们安装了以下软件：`kubectl`, `eksctl`, `helm`客户端，并安装了`Terraform`

### 创建VPC
我们创建一个独立的VPC，将EKS集群运行其中

'''bash
terraform init

terraform plan

terraform apply --auto-approve
'''

# 安装EKS集群



# 配置EKS的监控和观测功能


# 在EKS上部署简单的Web应用
## 将应用打包成为Docker镜像



## 将应用推送到ECR私有镜像仓库





# 体验EKS的自动扩展功能



# 通过FluentBit收集K8s日志以及应用日志



