# Container Insights CloudWatch implementation for EKS Cluster Observability

This module configures AWS CloudWatch Agent used for CloudWatch Application signals and Container Insights.

Use CloudWatch Application Signals to automatically instrument your applications on AWS so that you can monitor current application health and track long-term application performance against your business objectives. Application Signals provides you with a unified, application-centric view of your applications, services, and dependencies, and helps you monitor and triage application health.

Use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. CloudWatch automatically collects metrics for many resources, such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_observability_irsa_role"></a> [cloudwatch\_observability\_irsa\_role](#module\_cloudwatch\_observability\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | v5.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.amazon_cloudwatch_observability](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_service_linked_role.application_signals_cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.eks_addon_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_config"></a> [addon\_config](#input\_addon\_config) | Amazon EKS Managed CloudWatch Observability Add-on config | `any` | `{}` | no |
| <a name="input_create_cloudwatch_application_signals_role"></a> [create\_cloudwatch\_application\_signals\_role](#input\_create\_cloudwatch\_application\_signals\_role) | Create a Cloudwatch Application Signals service-linked role | `bool` | `true` | no |
| <a name="input_create_cloudwatch_observability_irsa_role"></a> [create\_cloudwatch\_observability\_irsa\_role](#input\_create\_cloudwatch\_observability\_irsa\_role) | Create a Cloudwatch Observability IRSA | `bool` | `true` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | Name of the EKS cluster | `string` | `"eks-cw"` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | The OIDC Provider ARN of AWS EKS cluster | `string` | `""` | no |
| <a name="input_enable_amazon_eks_cw_observability"></a> [enable\_amazon\_eks\_cw\_observability](#input\_enable\_amazon\_eks\_cw\_observability) | Enable Amazon EKS CloudWatch Observability add-on | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.28"` | no |
| <a name="input_most_recent"></a> [most\_recent](#input\_most\_recent) | Determines if the most recent or default version of the addon should be returned. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
