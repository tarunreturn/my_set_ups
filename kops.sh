#!/bin/bash

# Prompt user for input
read -p "Enter your AWS region: " REGION
read -p "Enter your S3 bucket name: " S3_BUCKET_NAME
read -p "Enter your cluster name: " CLUSTER_NAME

# AWS Configuration
aws configure

# Download kubectl and kops
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes/kops/releases/download/v1.25.0/kops-linux-amd64

# Make the binaries executable
chmod +x kops-linux-amd64 kubectl

# Move the binaries to /usr/local/bin
mv kubectl /usr/local/bin/kubectl
mv kops-linux-amd64 /usr/local/bin/kops

# Create S3 bucket with versioning enabled
aws s3api create-bucket --bucket $S3_BUCKET_NAME --region $REGION
aws s3api put-bucket-versioning --bucket $S3_BUCKET_NAME --region $REGION --versioning-configuration Status=Enabled

# Set KOPS_STATE_STORE environment variable
export KOPS_STATE_STORE=s3://$S3_BUCKET_NAME

# Create the Kubernetes cluster
kops create cluster --name $CLUSTER_NAME --zones $REGIONa --master-count=1 --master-size t2.medium --node-count=2 --node-size t2.medium

# Apply the changes to the cluster
kops update cluster --name $CLUSTER_NAME --yes --admin
