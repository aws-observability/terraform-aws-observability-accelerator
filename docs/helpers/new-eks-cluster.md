# Creating a new Amazon EKS cluster with VPC

!!! note
    This example is a subset from [this EKS Blueprint example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/v4.13.1/examples/eks-cluster-with-new-vpc)

This example deploys the following:

- New sample VPC, 3 Private Subnets and 3 Public Subnets
- Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- EKS Cluster Control plane with one managed node group

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.


## Setup

### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/eks-cluster-with-vpc/
terraform init
```

### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Additional configuration (optional)


### 1. Instance Type

Depending on your region or limitations in your account, you might need to change to a different instance type.
To do this, you can define the instance type to use:
```bash
export TF_VAR_managed_node_instance_type=xxx
```

### 2. Amazon Elastic Kubernetes Service (Amazon EKS) Version

You can override the version of the cluster also:
```bash
export TF_VAR_eks_version=xxx
```

##  Login to your cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
Use the following commands in your local machine where you want to interact with your EKS Cluster.

### 1. Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

### 2. List all the worker nodes by running the command below

    kubectl get nodes

### 3. List all the pods running in `kube-system` namespace

    kubectl get pods -n kube-system

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
