# Observability Module for ECS Monitoring using ecs_observer

This module provides ECS cluster monitoring with the following resources:

- AWS Distro For OpenTelemetry Operator and Collector for Metrics and Traces
- Creates Grafana Dashboards on Amazon Managed Grafana.
- Create SSM Parameter to store the ADOT config yaml file
- Creates Prometheus Dashboards on Amazon Managed Prometheus.

## Pre-requisites
1. ECS Cluster with EC2 under examples --> ecs-cluster-with-vpc
2. Update your exisitng App(workload) ECS Task Definition to add below label:
    Set ECS_PROMETHEUS_EXPORTER_PORT to point to the containerPort where the Prometheus metrics are exposed
    Set Java_EMF_Metrics to true. The CloudWatch agent uses this flag to generated the embedded metric format in the log event.
3. Make sure to update the placeholder values in the below files
    configs/config.yaml
    task_definitions/otel_collector.json


This module makes use of the below open source
[aws-managed-grafana](https://github.com/terraform-aws-modules/terraform-aws-managed-service-grafana)
[aws-managed-prometheus](https://github.com/terraform-aws-modules/terraform-aws-managed-service-prometheus)

See examples using this Terraform modules in the **Amazon ECS** section of [this documentation](https://aws-observability.github.io/terraform-aws-observability-accelerator/)

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
| <a name="module_managed_grafana_default"></a> [managed\_grafana\_default](#module\_managed\_grafana\_default) | terraform-aws-modules/managed-service-grafana/aws | n/a |
| <a name="module_managed_prometheus_default"></a> [managed\_prometheus\_default](#module\_managed\_prometheus\_default) | terraform-aws-modules/managed-service-prometheus/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.adot_ecs_prometheus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.adot_ecs_prometheus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ssm_parameter.adot-config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ecs_cluster_name"></a> [aws\_ecs\_cluster\_name](#input\_aws\_ecs\_cluster\_name) | Name of your ECS cluster | `string` | n/a | yes |
| <a name="input_executionRoleArn"></a> [executionRoleArn](#input\_executionRoleArn) | ARN of the IAM Execution Role | `string` | n/a | yes |
| <a name="input_taskRoleArn"></a> [taskRoleArn](#input\_taskRoleArn) | ARN of the IAM Task Role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_workspace_endpoint"></a> [grafana\_workspace\_endpoint](#output\_grafana\_workspace\_endpoint) | The endpoint of the Grafana workspace |
| <a name="output_grafana_workspace_id"></a> [grafana\_workspace\_id](#output\_grafana\_workspace\_id) | The ID of the Grafana workspace |
| <a name="output_prometheus_workspace_endpoint"></a> [prometheus\_workspace\_endpoint](#output\_prometheus\_workspace\_endpoint) | Prometheus endpoint available for this workspace |
| <a name="output_prometheus_workspace_id"></a> [prometheus\_workspace\_id](#output\_prometheus\_workspace\_id) | Identifier of the workspace |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
