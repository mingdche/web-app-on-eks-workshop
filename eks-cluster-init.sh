#!/bin/sh

# export VPC
export VPC_ID=$(terraform output -json | jq -r .vpc_id.value)
# export private subnets
export PRIVATE_SUBNETS_ID_A=$(terraform output -json | jq -r .private_subnets_id.value[0])
export PRIVATE_SUBNETS_ID_B=$(terraform output -json | jq -r .private_subnets_id.value[1])
export PRIVATE_SUBNETS_ID_C=$(terraform output -json | jq -r .private_subnets_id.value[2])
# export public subnets
export PUBLIC_SUBNETS_ID_A=$(terraform output -json | jq -r .public_subnets_id.value[0])
export PUBLIC_SUBNETS_ID_B=$(terraform output -json | jq -r .public_subnets_id.value[1])
export PUBLIC_SUBNETS_ID_C=$(terraform output -json | jq -r .public_subnets_id.value[2])

echo "VPC_ID=$VPC_ID, \
PRIVATE_SUBNETS_ID_A=$PRIVATE_SUBNETS_ID_A, \
PRIVATE_SUBNETS_ID_B=$PRIVATE_SUBNETS_ID_B, \
PRIVATE_SUBNETS_ID_C=$PRIVATE_SUBNETS_ID_C, \
PUBLIC_SUBNETS_ID_A=$PUBLIC_SUBNETS_ID_A, \
PUBLIC_SUBNETS_ID_B=$PUBLIC_SUBNETS_ID_B, \
PUBLIC_SUBNETS_ID_C=$PUBLIC_SUBNETS_ID_C"

cat > eks-cluster.yaml <<EOF
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: web-host-on-eks
  region: ap-southeast-1 # Specify the aws region
  version: "1.24"
privateCluster: # Allows configuring a fully-private cluster in which no node has outbound internet access, and private access to AWS services is enabled via VPC endpoints
  enabled: true
  additionalEndpointServices: # specifies additional endpoint services that must be enabled for private access. Valid entries are: "cloudformation", "autoscaling", "logs".
  - cloudformation
  - logs
  - autoscaling
vpc:
  id: "${VPC_ID}" # Specify the VPC_ID to the eksctl command
  subnets: # Creating the EKS master nodes to a completely private environment
    private:
      private-ap-east-1a: 
        id: "${PRIVATE_SUBNETS_ID_A}"
      private-ap-east-1b:
        id: "${PRIVATE_SUBNETS_ID_B}"
      private-ap-east-1c:
        id: "${PRIVATE_SUBNETS_ID_C}"
managedNodeGroups: # Create a managed node group in private subnets
- name: managed
  labels:
    role: worker
  instanceType: t3.small
  minSize: 3
  desiredCapacity: 3
  maxSize: 10
  privateNetworking: true
  volumeSize: 50
  volumeType: gp2
  volumeEncrypted: true
  iam:
    withAddonPolicies: 
      autoScaler: true # enables IAM policy for cluster-autoscaler
      albIngress: true 
      cloudWatch: true 
  # securityGroups:
  #    attachIDs: ["sg-1", "sg-2"]
  ssh:
      allow: true
      publicKeyPath: ~/.ssh/id_rsa.pub
      # new feature for restricting SSH access to certain AWS security group IDs
  subnets:
    - private-ap-east-1a
    - private-ap-east-1b
    - private-ap-east-1c
cloudWatch:
  clusterLogging:
    # enable specific types of cluster control plane logs
    enableTypes: ["all"]
    # all supported types: "api", "audit", "authenticator", "controllerManager", "scheduler"
    # supported special values: "*" and "all"
addons: # explore more on doc about EKS addons: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
- name: vpc-cni # no version is specified so it deploys the default version
  attachPolicyARNs:
    - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
- name: coredns
  version: latest # auto discovers the latest available
- name: kube-proxy
  version: latest
iam:
  withOIDC: true # Enable OIDC identity provider for plugins, explore more on doc: https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html
  serviceAccounts: # create k8s service accounts(https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) and associate with IAM policy, see more on: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  - metadata:
      name: aws-load-balancer-controller # create the needed service account for aws-load-balancer-controller while provisioning ALB/ELB by k8s ingress api
      namespace: kube-system
    wellKnownPolicies:
      awsLoadBalancerController: true
  - metadata:
      name: cluster-autoscaler # create the CA needed service account and its IAM policy
      namespace: kube-system
      labels: {aws-usage: "cluster-ops"}
    wellKnownPolicies:
      autoScaler: true
EOF
