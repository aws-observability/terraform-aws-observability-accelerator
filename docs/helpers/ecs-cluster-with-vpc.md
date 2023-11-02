# Example Amazon ECS Cluster with VPC
This example deploys an AWS ECS Cluster with VPC and also add the ECS Monitoring module

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.

## Setup
#### 1. Download sources and initialize Terraform¶

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd terraform-aws-observability-accelerator/examples/ecs-cluster-with-vpc
terraform init
```

#### 2. AWS Region¶
Specify the AWS Region where the resources will be deployed:

```
export TF_VAR_aws_region=xxx
```

#### 3. Terraform Plan to validate the changes/updates

```
terraform plan
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Cleanup

To clean up your environment, destroy the Terraform example by running

```sh
terraform destroy
```
