# EKS Cluster Deployment with new VPC

Note: This example is a subset from [this EKS Blueprint example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/v4.13.1/examples/eks-cluster-with-new-vpc)

This example deploys the following Basic EKS Cluster with VPC

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group

You can view the full documentation for this example [here](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/new-eks-cluster/)
