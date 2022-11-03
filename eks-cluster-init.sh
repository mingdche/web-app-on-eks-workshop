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

echo "Generating default ssh key in your Cloud9 environment"
ssh-keygen

echo "Creating EKS cluster"
eksctl create cluster -f eks-cluster.yaml

echo "Creating EKS cluster"
