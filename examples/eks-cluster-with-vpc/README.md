# EKS Cluster with VPC

Creates a ready-to-use EKS cluster for the observability accelerator examples.

## What it provisions

- VPC with 2 private and 2 public subnets, NAT gateway
- EKS cluster (default: v1.31) with a managed `t3.medium` node group
- Node IAM roles pre-configured with:
  - `CloudWatchAgentServerPolicy` — metrics/logs collection
  - `AmazonEC2ContainerRegistryReadOnly` — ECR image pulls

## Usage

```bash
terraform init
terraform apply -var="cluster_name=cw-otlp-test" -var="aws_region=us-east-1"
```

Then configure kubectl:

```bash
$(terraform output -raw configure_kubectl)
```

Use the cluster name in any monitoring example:

```bash
cd ../eks-cloudwatch-otlp
./install.sh -var="eks_cluster_id=cw-otlp-test" -var="aws_region=us-east-1"
```
