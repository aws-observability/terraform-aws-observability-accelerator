# Existing Cluster with the AWS Observability accelerator - Istio Monitoring


This example demonstrates how to use the AWS Observability Accelerator Terraform
modules to monitor Istio on Amazon EKS.
The current example deploys the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html) for Amazon EKS with its requirements and make use of existing
Amazon Managed Service for Prometheus and Amazon Managed Grafana workspaces.
Tetrate Istio EKS blueprint add-on

It provide an existing EKS cluster with an Istio add-on, OpenTelemetry collector,
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options on the cluster infrastructure.


## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [Grafana workspace id](https://docs.aws.amazon.com/grafana/latest/userguide/AMG-create-workspace.html)
5. Managed Prometheus workspace id 
```
Setup Amazon Managed Service for Prometheus workspace

A workspace in Amazon Managed Service for Prometheus is a logical space dedicated to storing and querying Prometheus metrics. A workspace supports fine-grained access control for authorizing its management updating, listing, describing, deleting, and the ingestion and querying of metrics.

Use the following command to create an Amazon Managed Service for Prometheus workspace:

aws amp create-workspace \
--alias $IAA_AMP_WORKSPACE_NAME \
--region $IAA_AWS_REGION

Creating the Amazon Managed service for Prometheus workspace takes just a few seconds.

You can improve security and performance by creating VPC-endpoint for Amazon Managed Service for Prometheus. For more information, see Using Amazon Service for Prometheus with interface VPC endpoints.
```
7. Grafana api key 
8. EKS cluster 


## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation

1. Clone the repo using the command below

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
```

2. Initialize terraform

```console
cd examples/existing-cluster-istio-monitoring
terraform init
```

3. Update variables.tf. Uncomment each of the defaults below with actual values for the name of the EKS cluster, aws_region, Prometheus workspace id, grafana workspace id and grafana api key.  

```
variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
#  default     = "eks-cluster-with-vpc"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
#  default     = "us-east-1" 
}
variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
#  default     = ""
}
variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
#  default     = ""
}
variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
#  default     = ""
  sensitive   = true
}
```


## Deploy

```sh
terraform apply
```

## Visualization

1. Prometheus datasource on Grafana

Open your Grafana workspace and under Configuration -> Data sources, you should see `aws-observability-accelerator`. Open and click `Save & test`. You should see a notification confirming that the Amazon Managed Service for Prometheus workspace is ready to be used on Grafana.

2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You should see a list of dashboards under the `Observability Accelerator Dashboards`

<img width="1540" alt="image" src="https://user-images.githubusercontent.com/10175027/190000716-29e16698-7c90-49d6-8c37-79ca1790e2cc.png">

Open a specific dashboard and you should be able to view its visualization

<img width="1721" alt="Screenshot 2022-08-30 at 20 01 32" src="https://user-images.githubusercontent.com/10175027/187515925-67864dd1-2b35-4be0-a15e-1e36805e8b29.png">

2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you should find new rules deployed.

<img width="1629" alt="image" src="https://user-images.githubusercontent.com/10175027/189301297-4865e75d-2d71-434f-b5d0-9750b3533632.png">


To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)

## Advanced configuration

1. Cross-region Amazon Managed Prometheus workspace

If your existing Amazon Managed Prometheus workspace is in another AWS Region,
add this `managed_prometheus_region=xxx` and `managed_prometheus_workspace_id=ws-xxx`.

2. Cross-region Amazon Managed Grafana workspace

If your existing Amazon Managed Prometheus workspace is in another AWS Region,
add this `managed_prometheus_region=xxx` and `managed_prometheus_workspace_id=ws-xxx`.

## Destroy resources

If you leave this stack running, you will incur charges. To remove all resources
created by Terraform, [refresh your Grafana API key](#apikey) and run:

```sh
terraform destroy -var-file=terraform.tfvars
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.25.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_observability_accelerator"></a> [eks\_observability\_accelerator](#module\_eks\_observability\_accelerator) | ../../ | n/a |
| <a name="module_workloads_infra"></a> [workloads\_infra](#module\_workloads\_infra) | ../../modules/workloads/infra | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | `""` | no |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | Amazon Managed Grafana Workspace ID | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Service for Prometheus Workspace ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS Region |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS Cluster version |
| <a name="output_grafana_dashboard_urls"></a> [grafana\_dashboard\_urls](#output\_grafana\_dashboard\_urls) | URLs for dashboards created |
| <a name="output_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#output\_managed\_grafana\_workspace\_id) | Amazon Managed Grafana workspace ID |
| <a name="output_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#output\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus workspace endpoint |
| <a name="output_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#output\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus workspace ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
