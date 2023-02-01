# Concepts

## Prerequisites

All examples in this repository require the following tools installed

1. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)

### Minimum IAM Policy

To run the examples, you need a set of AWS IAM permissions. You can find an example of minimum
permissions required [in this file](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/docs/iam/min-iam-policy.json).

> **Note**: The policy resource is set as `*` to allow all resources, this is not a recommended practice.
You should restrict instead to the ARNs when applicable.

### Terraform states and variables

By default, our examples are using local Terraform states. If you need
your Terraform states to be saved remotely, on Amazon S3, visit the
[terraform remote states](https://www.terraform.io/language/state/remote) documentation.

For simplicity, we use Terraform supported environment variables.
You can also edit the `terraform.tfvars` files directly and deploy
with `terraform apply -var-file=terraform.tfvars`. Terraform tfvars file can be useful if
you need to track changes as part of a Git repository or CI/CD pipeline.

> **Note:** When using `tfvars` files, always be careful to not store and commit any secrets (keys, passwords, ...)

## Base module

The base module allows you to configure the AWS Observability services for your cluster and
the AWS Distro for OpenTelemetry (ADOT) Operator as the signals collection mechanism.

This is the minimum configuration to have a new Amazon Managed
Service for Prometheus Workspace, ADOT Operator deployed for you and ready to receive your
data. The base module serve as an anchor to the workload modules and cannot run on its own.

```hcl
module "eks_observability_accelerator" {
  source          = "aws-observability/terraform-aws-observability-accelerator"
  aws_region      = "eu-west-1"
  eks_cluster_id  = "my-eks-cluster"

  # As Grafana shares a different lifecycle, it is best to use an existing workspace.
  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  grafana_api_key              = var.grafana_api_key
}
```

You can optionally reuse an existing Amazon Managed Servce for Prometheus Workspaces:

```hcl
module "eks_observability_accelerator" {
  source = "aws-observability/terraform-aws-observability-accelerator"
  aws_region = "eu-west-1"
  eks_cluster_id = "my-eks-cluster"

  # prevents creation of a new Amazon Managed Prometheus workspace
  enable_managed_prometheus = false

  # reusing existing Amazon Managed Prometheus Workspace
  managed_prometheus_workspace_id     = "ws-abcd123..."

  managed_grafana_workspace_id = "g-abcdef123"
  grafana_api_key              = var.grafana_api_key
}
```

View all the configuration options in the [module's documentation](https://github.com/aws-observability/terraform-aws-observability-accelerator#requirements)

## Workload modules

Workloads modules are focused Terraform modules provided in this repository. They essentially provide curated metrics collection, alerts and Grafana dashboards according to the use case. Most of those modules require the base module.

You can check the full workload modules list and their documentation [here](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/workloads).

All the modules come with end-to-end deployable examples.

## Examples

[Examples](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/examples) put modules together in a ready to deploy terraform configuration as a starting point. With little to no configuration, you can run `terraform apply` and use the deployed resources on your AWS Account.

You can find **workload** examples like [Amazon EKS infrstructure monitoring](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/) or [monitoring your Amazon Managed Service for Prometheus workspace](https://aws-observability.github.io/terraform-aws-observability-accelerator/workloads/managed-prometheus/) and more.


## Getting started with AWS Observability services

If you are new to AWS Observability services, or want to dive deeper into them, check our [One Observability Workshop](https://catalog.workshops.aws/observability/) for a hands-on experience in a self-paced environement or at an AWS venue.
