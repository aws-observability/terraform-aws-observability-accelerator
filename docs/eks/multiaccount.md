# AWS EKS Cross Account Observability

This example shows how to use the [AWS Observability Accelerator](https://github.com/aws-observability/terraform-aws-observability-accelerator), with two or more EKS clusters in multiple AWS accounts and verify the collected metrics from all the clusters in the dashboards of a common `Amazon Managed Grafana` workspace in a central monitoring account.

## Prerequisites

#### 1. Cross Account IAM access

In order to create/modify resources across multiple AWS accounts, this Terraform example implements the cross-account IAM role assumption. You will need separate IAM roles in all 3 AWS accounts, and each of these IAM roles should have the below specified trust-relationship so that your local AWS user/role will be able to assume them during the terraform execution.

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

!!! note
    The IAM roles in Account 1 and Account 2 (EKS cluster accounts) should have permissions to perform kubernetes API operations against your EKS clusters. For more info, please review documentation for [enabling IAM principal access to your clusters](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)

#### 2. EKS clusters in multiple AWS Accounts

Using the example [eks-cluster-with-vpc](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/new-eks-cluster/), create two EKS clusters with the below names in two different AWS accounts:

1.  `eks-cluster-1` (Account 1)

2.  `eks-cluster-2` (Account 2)

Update the cluster names and their corresponding region names in the `variables.tf` file along with the corresponding IAM role ARNs that can be assumed by terraform to perform cross-account API operations.

#### 3. Amazon Managed Grafana (AMG) workspace

To run this example you need an existing Amazon Managed Grafana (AMG) workspace. If not, you can create a new AMG workspace by following the [Getting Started with Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html) documentation.

Add the Grafana Workspace ID and its corresponding region name in the `variables.tf` file along with the corresponding IAM role ARN that can be assumed by terraform to perform cross-account API operations.

!!! note
    You can obtain the AMG Workspace ID based on its URL. For the URL `https://g-xyz.grafana-workspace.eu-central-1.amazonaws.com`, the workspace ID would be `g-xyz`


## Setup

#### 1. Download sources and initialize Terraform


```sh

git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git

cd terraform-aws-observability-accelerator/examples/eks-cross-account-with-central-amp

terraform init

```

#### 2. Deploy

By looking at the `variables.tf`, you will notice there are two EKS clusters targeted for deployment by the names/ids:

1.  `eks-cluster-1`

2.  `eks-cluster-2`

While installing the observability settings for the EKS cluster specified in variable `cluster_one.name`, Terraform also sets up:

* Creates an `Amazon Managed Prometheus Workspace`

* Dashboard folder and files in provided `Amazon Managed Grafana Workspace`


!!! warning
    To override the defaults, create a `terraform.tfvars` and change the default values of the variables.



Run the following command to deploy

```sh

terraform  apply  --auto-approve

```



## Verifying Multi Account Observability



One you have successfully run the above setup, you should be able to see dashboards similar to the images shown below in `Amazon Managed Grafana` workspace.



You will notice that you are able to use the `cluster` dropdown to filter the dashboards to metrics collected from a specific EKS cluster.

![eks-cross-account-1](https://github.com/veekaly/terraform-aws-observability-accelerator/assets/119073483/96a68eb1-4fb7-4a6b-bd4a-15f4f6ac7565)
![eks-cross-account-2](https://github.com/veekaly/terraform-aws-observability-accelerator/assets/119073483/1373b834-1082-4a63-98b9-2b90fb32eada)


## Cleanup

To clean up entirely, run the following command:



```sh

terraform  destroy  --auto-approve

```
