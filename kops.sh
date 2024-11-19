#run this commands mannual if run on linux u can ingnore it if use unbuntu
#vim .bashrc
#export PATH=$PATH:/usr/local/bin/
#source .bashrc
#!/bin/bash
# Prompt user for input
read -p "Enter your AWS region (eg:us-east-1): " REGION
read -p "Enter your S3 bucket name (e.g., mys3.k8s.local): " S3_BUCKET_NAME
read -p "Enter your cluster name (e.g., mycluster.k8s.local): " CLUSTER_NAME

# AWS Configuration or if u use IAM role ingnore it
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

# Create the Kubernetes cluster with explicit cloud provider (AWS)
kops create cluster --name $CLUSTER_NAME --zones ${REGION}a --cloud aws --master-count=1 --master-size t2.medium --node-count=2 --node-size t2.micro

# Apply the changes to the cluster
kops update cluster --name $CLUSTER_NAME --yes --admin
