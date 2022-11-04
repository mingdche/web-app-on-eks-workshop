# 将Web应用运行于EKS
本实验活动通过动手实践的方式帮助您了机EKS，在本次实验活动中您将体验到如下：
1. 通过eksctl创建EKS集群
2. 配置EKS的监控和观测功能
3. 在EKS上部署简单的Web应用
4. 体验EKS的自动扩展功能
5. 通过FluentBit收集K8s日志以及应用日志

# 准备活动
### 安装相关软件
```bash
git clone https://github.com/mingdche/web-app-on-eks-workshop 

cd web-app-on-eks-workshop


./init.sh
```

以上命令为我们安装了以下软件：`kubectl`, `eksctl`, `helm`客户端，并安装了`Terraform`

### 创建VPC
'''bash
./vpc-init.sh
'''

我们将EKS集群运行于该VPC内




