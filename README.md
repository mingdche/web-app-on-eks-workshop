# 将Web应用运行于EKS
本实验活动通过动手实践的方式帮助您了解EKS，在本次实验活动中您将体验到如下：
1. 通过terraform创建EKS集群
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

以上命令为我们安装了以下软件：`kubectl`, `eksctl`, `helm`客户端，并安装了`Terraform` 并配置了后续脚本命令所需的环境变量 `AWS_REGION`，`ACCOUNT_ID` 

### 创建VPC
我们创建一个独立的VPC，将EKS集群运行其中

```bash
terraform init

terraform plan

terraform apply --auto-approve
```

# 安装EKS集群



# 配置EKS的监控和观测功能


# 在EKS上部署简单的Web应用
## 将应用打包成为Docker镜像



## 将应用镜像推送到ECR私有镜像仓库
1. 登录ECR镜像仓库
```bash
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```
2. 创建名为web-app-repo的镜像仓库
```bash
aws ecr create-repository \
    --repository-name front-end \
    --image-scanning-configuration scanOnPush=true \
    --region ${AWS_REGION}
```
3. 给Docker打标签
```bash
docker tag front-end:latest ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/front-end
```

4. 将镜像push到镜像仓库web-app-repo
```bash
docker push ${ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com/front-end
```

5. 部署应用
生成部署文件
```bash
cat > /home/ec2-user/environment/web-app-on-eks-workshop/app/deploy.yaml <<EOF
apiVersion: v1
kind: Namespace # create the namespace for this application
metadata:
  name: front-end
---
apiVersion: apps/v1
kind: Deployment 
metadata:
  name: front-end-deployment
  namespace: front-end
spec:
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: front-end
        image: ${ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com/front-end # specify your ECR repository
        ports:
        - containerPort: 3000 
        resources:
            limits:
              cpu: 500m
            requests:
              cpu: 250m
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: front-end-hpa
  namespace: front-end
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: front-end-deployment
  minReplicas: 1 
  maxReplicas: 100
  targetCPUUtilizationPercentage: 10 # define the replicas range and the scaling policy for the deployment
---
apiVersion: v1
kind: Service
metadata:
  name: front-end-service
  namespace: front-end
  labels:
    app: front-end
spec:
  selector:
    app: front-end
  ports:
    - protocol: TCP
      port: 3000 
      targetPort: 3000
  type: NodePort # expose the service as NodePort type so that ALB can use it later.
EOF
```
通过以下命令创建`front-end`命名空间、`front-hpa`HPA、`front-end-service`服务。 
```bash
kubectl apply -f deploy.yaml
```

执行以下命令将看到部署的情况
```bash
kubectl get pods -n front-end
```

## 将应用曝露在互联网上
在上述步骤中，我们创建了名为front-end-service的服务，仅创建服务还不够，为了让互联网上的流量能够访问到我们刚才部署的服务，我们需要部署aws-load-balancer-controller.

我们将使用Helm来完成这些工作
```bash
helm repo add eks https://aws.github.io/eks-charts

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
```

export 公共子网的子网ID
```bash
export PUBLIC_SUBNETS_ID_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=web-app-on-eks-workshop-public-${AWS_REGION}a" | jq -r .Subnets[].SubnetId)
export PUBLIC_SUBNETS_ID_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=web-app-on-eks-workshop-public-${AWS_REGION}b" | jq -r .Subnets[].SubnetId)
export PUBLIC_SUBNETS_ID_C=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=web-app-on-eks-workshop-public-${AWS_REGION}c" | jq -r .Subnets[].SubnetId)

```

创建ingress配置文件
```bash
cat > /home/ec2-user/environment/web-app-on-eks-workshop/app/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: front-end
  name: ingress-front-end
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip # using IP routing policy of ALB
    alb.ingress.kubernetes.io/subnets: $PUBLIC_SUBNETS_ID_A, $PUBLIC_SUBNETS_ID_B, $PUBLIC_SUBNETS_ID_C # specifying the public subnets id
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: front-end-service # refer to the service defined in deploy.yaml
                port:
                  number: 3000
EOF
```

# 体验EKS的自动扩展功能

Cluster AutoScaler

Kapenter？


# 通过FluentBit收集K8s日志以及应用日志



Loghub




