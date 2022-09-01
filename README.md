# AWS Observability Accelerator for Terraform

Welcome to the AWS Observability Accelerator for Terraform!

The AWS Observability accelerator for Terraform is a set of modules to help you
configure Observability for your Amazon EKS clusters with AWS Observability services.
This project proposes a core module to bootstrap your cluster with the AWS Distro for
OpenTelemetry (ADOT) Operator for EKS, Amazon Managed Service for Prometheus (AMP),
Amazon Managed Grafana (AMG). Additionally we have a set of workloads modules to
leverage curated ADOT collector configurations, Grafana dashboards,
Prometheus recording rules and alerts.

You can check our [examples](./examples) for different end-to-end integrations scenarios.

We will be leveraging [EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
repository to deploy the solution.

## Example Usage

The sections below demonstrate how you can leverage AWS Observability Accelerator
to enable monitoring to an existing EKS cluster.

### Base Module

The base module allows you to configure the AWS Observability services for your cluster and
the AWS Distro for OpenTelemetry (ADOT) Operator as the signals collection mechanism.

This is the minimum configuration to have a new Managed Grafana Workspace, Amazon Managed
Service for Prometheus Workspace, ADOT Operator deployed for you and ready to receive your
data.

```hcl
module "eks_observability_accelerator" {
  source = "aws-observability/terrarom-aws-observability-accelerator"
  aws_region = "eu-west-1"
  eks_cluster_id = "my-eks-cluster"
}
```

You can optionally reuse existing Workspaces:

```hcl
module "eks_observability_accelerator" {
  source = "aws-observability/terrarom-aws-observability-accelerator"
  aws_region = "eu-west-1"
  eks_cluster_id = "my-eks-cluster"

  # prevents creation of a new AMP workspace
  enable_managed_prometheus = false

  # reusing existing AMP
  managed_prometheus_workspace_id     = "ws-abcd123..."

  # prevents creation of a new AMG workspace
  enable_managed_grafana       = false

  managed_grafana_workspace_id = "g-abcdef123"
  grafana_api_key              = var.grafana_api_key
}
```

View all the configuration options in the module documentation below.

### Workload modules

Workload modules are provided, which essentially provide curated
metrics collection, alerting rule and Grafana dashboards.


#### Infrastructure monitoring



```hcl
module "workloads_infra" {
  source = "aws-observability/terrarom-aws-observability-accelerator/workloads/infra"

  eks_cluster_id = module.eks_observability_accelerator.eks_cluster_id

  dashboards_folder_id            = module.eks_observability_accelerator.grafana_dashboards_folder_id
  managed_prometheus_workspace_id = module.eks_observability_accelerator.managed_prometheus_workspace_id

  managed_prometheus_workspace_endpoint = module.eks_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.eks_observability_accelerator.managed_prometheus_workspace_region
}
```

Grafana Dashboards

<img width="1719" alt="image" src="https://user-images.githubusercontent.com/10175027/187661363-608cdfcf-ed13-4ddd-a198-e761b78d2291.png">


To quickstart with a complete workflow and view other dashboards, visit the [existing cluster with base and module example](./examples/existing-cluster-with-base-and-infra/)


## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy and manage containerized applications at scale. The extensible nature of Kubernetes also allows you to use a wide range of popular open-source tools, commonly referred to as add-ons, in Kubernetes clusters. With such a large number of tools and design choices available, building a tailored EKS cluster that meets your application’s specific needs can take a significant amount of time. It involves integrating a wide range of open-source tools and AWS services and requires deep expertise in AWS and Kubernetes.

AWS customers have asked for examples that demonstrate how to integrate the landscape of Kubernetes tools and make it easy for them to provision complete, opinionated EKS clusters that meet specific application requirements. Customers can use AWS Observability Accelerator to configure and deploy purpose built EKS clusters, and start onboarding workloads in days, rather than months.

## Support & Feedback

AWS Oservability Accelerator for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the AWS Oservability Accelerator community.

To post feedback, submit feature ideas, or report bugs, please use the Issues (https://github.com/aws-observability/terraform-aws-observability-accelerator/issues) section of this GitHub repo.

If you are interested in contributing to EKS Blueprints, see the Contribution (https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/CONTRIBUTING.md) guide.

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 1.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_grafana"></a> [managed\_grafana](#module\_managed\_grafana) | terraform-aws-modules/managed-service-grafana/aws | ~> 1.3 |
| <a name="module_operator"></a> [operator](#module\_operator) | ./modules/add-ons/adot-operator | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_alert_manager_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_alert_manager_definition) | resource |
| [aws_prometheus_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [grafana_data_source.amp](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/data_source) | resource |
| [grafana_folder.this](https://registry.terraform.io/providers/grafana/grafana/1.25.0/docs/resources/folder) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/grafana_workspace) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_enable_alertmanager"></a> [enable\_alertmanager](#input\_enable\_alertmanager) | Creates AMP AlertManager for all workloads | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_adot"></a> [enable\_amazon\_eks\_adot](#input\_enable\_amazon\_eks\_adot) | Enables the ADOT Operator on the EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Allow reusing an existing installation of cert-manager | `bool` | `true` | no |
| <a name="input_enable_managed_grafana"></a> [enable\_managed\_grafana](#input\_enable\_managed\_grafana) | Creates a new Amazon Managed Grafana (AMG) Workspace | `bool` | `true` | no |
| <a name="input_enable_managed_prometheus"></a> [enable\_managed\_prometheus](#input\_enable\_managed\_prometheus) | Creates a new AMP workspace | `bool` | `true` | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Grafana API key for the AMG workspace | `string` | `null` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_managed_grafana_region"></a> [managed\_grafana\_region](#input\_managed\_grafana\_region) | Region where AMG is deployed | `string` | `null` | no |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | AMG Workspace ID | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | AMP Workspace ID | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#input\_managed\_prometheus\_workspace\_region) | Region where AMP is deployed | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | EKS Cluster Id |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | n/a |
| <a name="output_grafana_dashboards_folder_id"></a> [grafana\_dashboards\_folder\_id](#output\_grafana\_dashboards\_folder\_id) | n/a |
| <a name="output_managed_grafana_workspace_endpoint"></a> [managed\_grafana\_workspace\_endpoint](#output\_managed\_grafana\_workspace\_endpoint) | n/a |
| <a name="output_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#output\_managed\_prometheus\_workspace\_endpoint) | n/a |
| <a name="output_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#output\_managed\_prometheus\_workspace\_id) | n/a |
| <a name="output_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#output\_managed\_prometheus\_workspace\_region) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-observability/terraform-aws-eks-blueprints/blob/main/LICENSE).
