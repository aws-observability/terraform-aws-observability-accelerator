# AWS EKS Cross Cluster Observability with cross account AMP/AMG

This example shows how to use the [AWS Observability Accelerator](https://github.com/aws-observability/terraform-aws-observability-accelerator), with more than one EKS cluster in multiple accounts and verify the collected metrics from all the clusters in the dashboards of a common `Amazon Managed Grafana` workspace in a central monitoring account.

## Prerequisites

#### 1. Cross Account IAM access

Create IAM roles with `AdministratorAccess` in all 3 AWS accounts i.e. EKS Cluster 1, EKS Cluster 2 and the central Monitoring Account that hosts AMP/AMG, and allow the local IAM user/role to assume the above created roles in their trust-relationship policy as below.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<local-aws-user/role-arn>"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
```

During terraform execution, the local AWS user/role will assume the cross account IAM roles to create/update/delete the resources in their respective accounts.

## Setup

#### 1. Download sources and initialize Terraform

```sh
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd terraform-aws-observability-accelerator/examples/eks-cross-account-with-central-amp
terraform init
```

#### 2. Deploy

Update the file `variables.tf` by adding the cluster information, AMP/AMG information, and the above created cross-account IAM roles.

!!! warning
    To override the defaults, create a `terraform.tfvars` and change the default values of the variables.

Run the following command to deploy

```sh
terraform apply --auto-approve
```

## Verifying Multi account EKS Observability

One you have successfully run the above setup, you should be able to see dashboards similar to the images shown below in `Amazon Managed Grafana` workspace.

Note how you are able to use the `cluster` dropdown to filter the dashboards to metrics collected from a specific EKS cluster.

<img width="2557" alt="eks-multicluster-1" src="https://user-images.githubusercontent.com/4762573/233949110-ce275d06-7ad8-494c-b527-d9c2a0fb6645.png">

<img width="2560" alt="eks-multicluster-2" src="https://user-images.githubusercontent.com/4762573/233949227-f401f81e-e0d6-4242-96ad-0bcd39ad4e2d.png">

## Cleanup

To clean up entirely, run the following command:

```sh
terraform destroy --auto-approve
```
