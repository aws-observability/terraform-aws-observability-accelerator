# Creating a new Amazon Managed Grafana Workspace

This example creates an Amazon Managed Grafana Workspace with
Amazon CloudWatch, AWS X-Ray and Amazon Managed Service for Prometheus
datasources.

The authentication method chosen for this example is with IAM Identity
Center (former SSO). You can extend this example to add SAML.

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.

## Setup

### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/managed-grafana-workspace
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

## Authentication

After apply, Terraform will output the Worksapce's URL, but you need to:

- [Setup user(s)](https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html) in the IAM Identity Center (former SSO)
- [Assign the user(s) to the workspace](https://docs.aws.amazon.com/grafana/latest/userguide/AMG-manage-users-and-groups-AMG.html) with proper permissions

<img width="1936" alt="Screenshot 2023-03-19 at 12 04 45" src="https://user-images.githubusercontent.com/10175027/226172947-f8588ed3-3751-47c1-a3ed-fb4c2d4d847e.png">


## Cleanup

To clean up your environment, destroy the Terraform example by running

```sh
terraform destroy
```
