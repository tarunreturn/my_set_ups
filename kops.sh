#First run this commands mannual if any binary files dowmloaded we need to export path by below commands
#vim .bashrc
#export PATH=$PATH:/usr/local/bin/
#source .bashrc

#!/bin/bash
# Prompt user for S3 bucket name and cluster name
read -p "Enter the S3 bucket name: " S3_BUCKET_NAME
read -p "Enter the cluster name: " CLUSTER_NAME

# Install kubectl
echo "Downloading kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kops
echo "Downloading kops..."
wget https://github.com/kubernetes/kops/releases/download/v1.25.0/kops-linux-amd64

# Make binaries executable
chmod +x kubectl kops-linux-amd64

# Move binaries to /usr/local/bin
mv kubectl /usr/local/bin/kubectl
mv kops-linux-amd64 /usr/local/bin/kops

# Create S3 bucket
echo "Creating S3 bucket: $S3_BUCKET_NAME..."
aws s3api create-bucket --bucket $S3_BUCKET_NAME --region us-east-1
aws s3api put-bucket-versioning --bucket $S3_BUCKET_NAME --region us-east-1 --versioning-configuration Status=Enabled

# Set the KOPS_STATE_STORE environment variable
export KOPS_STATE_STORE=s3://$S3_BUCKET_NAME

# Create cluster configuration
echo "Creating Kubernetes cluster: $CLUSTER_NAME..."
kops create cluster --name $CLUSTER_NAME --zones us-east-1a --master-count=1 --master-size t2.medium --node-count=2 --node-size t2.medium

# Deploy the cluster
echo "Deploying Kubernetes cluster..."
kops update cluster --name $CLUSTER_NAME --yes --admin

# Print success message
echo "Cluster $CLUSTER_NAME created successfully. Validate with 'kops validate cluster'."
