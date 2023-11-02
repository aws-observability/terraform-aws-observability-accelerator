# Observability Module for ECS Monitoring using ecs_observer

This module provides ECS cluster monitoring with the following resources:

- AWS Distro For OpenTelemetry Operator and Collector for Metrics and Traces
- Creates Grafana Dashboards on Amazon Managed Grafana.
- Creates SSM Parameter to store and distribute the ADOT config file

## Pre-requisites
* ECS Cluster with EC2 using examples --> ecs-cluster-with-vpc
* Create a `Prometheus Workspace` either using the Console or using the commented code under modules/ecs-monitoring/main.tf.
* Update your exisitng App(workload) *ECS Task Definition* to add below label/environment variable
    - Set ***ECS_PROMETHEUS_EXPORTER_PORT*** to point to the containerPort where the Prometheus metrics are exposed
    - Set ***Java_EMF_Metrics*** to true. The CloudWatch agent uses this flag to generated the embedded metric format in the log event.

This module makes use of the below open source projects:
* [aws-managed-grafana](https://github.com/terraform-aws-modules/terraform-aws-managed-service-grafana)
* [aws-managed-prometheus](https://github.com/terraform-aws-modules/terraform-aws-managed-service-prometheus)

See examples using this Terraform modules in the **Amazon ECS** section of [this documentation](https://aws-observability.github.io/terraform-aws-observability-accelerator/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_grafana_default"></a> [managed\_grafana\_default](#module\_managed\_grafana\_default) | terraform-aws-modules/managed-service-grafana/aws | 2.1.0 |
| <a name="module_managed_prometheus_default"></a> [managed\_prometheus\_default](#module\_managed\_prometheus\_default) | terraform-aws-modules/managed-service-prometheus/aws | 2.2.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.adot_ecs_prometheus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.adot_ecs_prometheus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ssm_parameter.adot_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ecs_cluster_name"></a> [aws\_ecs\_cluster\_name](#input\_aws\_ecs\_cluster\_name) | Name of your ECS cluster | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Container Name for Adot | `string` | `"adot_new"` | no |
| <a name="input_create_managed_grafana_ws"></a> [create\_managed\_grafana\_ws](#input\_create\_managed\_grafana\_ws) | Creates a Workspace for Amazon Managed Grafana | `bool` | `true` | no |
| <a name="input_create_managed_prometheus_ws"></a> [create\_managed\_prometheus\_ws](#input\_create\_managed\_prometheus\_ws) | Creates a Workspace for Amazon Managed Prometheus | `bool` | `true` | no |
| <a name="input_ecs_adot_cpu"></a> [ecs\_adot\_cpu](#input\_ecs\_adot\_cpu) | CPU to be allocated for the ADOT ECS TASK | `string` | `"256"` | no |
| <a name="input_ecs_adot_mem"></a> [ecs\_adot\_mem](#input\_ecs\_adot\_mem) | Memory to be allocated for the ADOT ECS TASK | `string` | `"512"` | no |
| <a name="input_ecs_metrics_collection_interval"></a> [ecs\_metrics\_collection\_interval](#input\_ecs\_metrics\_collection\_interval) | Collection interval for ecs metrics | `string` | `"15s"` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the IAM Execution Role | `string` | n/a | yes |
| <a name="input_otel_image_ver"></a> [otel\_image\_ver](#input\_otel\_image\_ver) | Otel Docker Image version | `string` | `"v0.31.0"` | no |
| <a name="input_otlp_grpc_endpoint"></a> [otlp\_grpc\_endpoint](#input\_otlp\_grpc\_endpoint) | otlpGrpcEndpoint | `string` | `"0.0.0.0:4317"` | no |
| <a name="input_otlp_http_endpoint"></a> [otlp\_http\_endpoint](#input\_otlp\_http\_endpoint) | otlpHttpEndpoint | `string` | `"0.0.0.0:4318"` | no |
| <a name="input_refresh_interval"></a> [refresh\_interval](#input\_refresh\_interval) | Refresh interval for ecs\_observer | `string` | `"60s"` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ARN of the IAM Task Role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_workspace_endpoint"></a> [grafana\_workspace\_endpoint](#output\_grafana\_workspace\_endpoint) | The endpoint of the Grafana workspace |
| <a name="output_grafana_workspace_id"></a> [grafana\_workspace\_id](#output\_grafana\_workspace\_id) | The ID of the Grafana workspace |
| <a name="output_prometheus_workspace_id"></a> [prometheus\_workspace\_id](#output\_prometheus\_workspace\_id) | Identifier of the workspace |
| <a name="output_prometheus_workspace_prometheus_endpoint"></a> [prometheus\_workspace\_prometheus\_endpoint](#output\_prometheus\_workspace\_prometheus\_endpoint) | Prometheus endpoint available for this workspace |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
