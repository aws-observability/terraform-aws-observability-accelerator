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
7. [Grafana api key with Admin role](https://docs.aws.amazon.com/grafana/latest/userguide/API_key_console.html)
8. Create an EKS cluster by following the readme below 

[https://github.com/awsdabra/terraform-aws-observability-accelerator/tree/main/examples/eks-cluster-with-vpc](https://github.com/awsdabra/terraform-aws-observability-accelerator/blob/main/examples/eks-cluster-with-vpc/README.md)








## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation

1. Clone the repo using the command below

```
git clone https://github.com/awsdabra/terraform-aws-observability-accelerator
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


![8184A2F7-C9BD-4F96-BA1C-2D11E951C287](https://user-images.githubusercontent.com/47993564/236841811-fdd5a07c-6e5e-4654-a735-80f92f5bee56.jpeg)


Open a specific dashboard and you should be able to view its visualization. Example below is for the Istio Control Plane Dashboard with data for the last hour. 

![68AC86D7-4959-4527-A723-A19E8FD9E8F5](https://user-images.githubusercontent.com/47993564/236842708-72225322-4f97-44cc-aac0-40a3356e50c6.jpeg)


2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you should find new rules deployed.

![E621F573-2D6E-42A0-A997-5941BDBCB3FA](https://user-images.githubusercontent.com/47993564/236844084-80c754e3-4fe1-45bb-8361-181432675469.jpeg)



To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)

3. Configure the Prometheus data source

For Default Region, choose the region where you created the Amazon Managed Service for Prometheus workspace

Select the Save and test button. You will see data source working.

4. Query Istio metrics

Now import the Grafana dashboards to enable visualizing metrics from the Istio environment. Go to the plus sign on the left navigation bar, and select Import, as shown in the following image.

Type 7639 (Istio Mesh Dashboard) in the Import via grafana.com textbox in the Import screen and select Load. Select the Prometheus data source in the dropdown at the bottom and choose Import. Once complete, you will be able to see the Grafana dashboard showing metrics from the Istio through the Prometheus data source.

You should edit the underlying PromQL queries in the dashboard JSON from [1m] to [5m] if the dashboard panel is empty for the Global Request Volume and HTTP workloads panels. Additional Grafana dashboards for Istio components are available at grafana.com.
More Istio metrics

5. Segmenting by service and service version, these are a few metrics that you usually want to monitor coming from the Istio Prometheus telemetry:

    Number of requests: istio_request_count
    Request duration: istio_request_duration_milliseconds_bucket by source and destination
    Request size: istio_request_bytes_bucket by source and destination

You can also create your custom dashboard using PromQL (Prometheus Query Language) by creating a custom dashboard. Then add a panel connecting Amazon Managed service for Prometheus as the data source.
Setting up alerts with Amazon Managed Grafana and PagerDuty for Istio HA

6. Having a centralized incident management process is critical to keeping systems running smoothly. You integrate PagerDuty with Amazon Managed Grafana to monitor Istio metrics and configure alerts. View more details on alerting in and various supported providers at alert notifications for Amazon Managed Grafana.

PagerDuty is an alarm aggregation and dispatching service for system administrators and support teams. It collects alerts from your monitoring tools, provides an overall view of your monitoring alarms, and alerts an on-duty engineer if there’s a problem. To integrate PagerDuty with Amazon Managed Grafana, you can use an existing account or create a new account with free trial on PagerDuty.

Next, log in to your PagerDuty account. Under the Create a Service section, provide a name and description, as shown in the following image.

Select next, and continue selecting next on the upcoming two screens to choose default values. Then, choose API Events V2 and Submit on the integrations page, as shown in the following.

Create a Service Screen

You will see the following screen for the created service with an Integration Key to use for configuring Amazon Managed Grafana for alerting:

Now, Let’s create a notification channel in Amazon Managed Grafana.

Go to the bell icon on left as shown below and click on  Notification channels Tab.

Choose the Add channel button to see the following screen and populate the fields – Name, Type, and Integration Key (from PagerDuty), as follows:

Next, select Test to generate a notification to PagerDuty and select Save.

Switch back to the PagerDuty screen, and navigate to the home page. You will see an alert displayed as follows:

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
