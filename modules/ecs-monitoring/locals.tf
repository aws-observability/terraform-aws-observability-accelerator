data "aws_region" "current" {}

locals {
  taskRoleArn      = var.taskRoleArn
  executionRoleArn = var.executionRoleArn
  region           = data.aws_region.current.name
  name             = "amg-ex-${replace(basename(path.cwd), "_", "-")}"
  description      = "AWS Managed Grafana service for ${local.name}"

  default_otel_values = {
    aws_region                      = data.aws_region.current.name
    cluster_name                    = var.aws_ecs_cluster_name
    cluster_region                  = data.aws_region.current.name
    refresh_interval                = "60s"
    ecs_metrics_collection_interval = "15s"
    amp_remote_write_ep             = "https://aps-workspaces.us-east-1.amazonaws.com/workspaces/ws-f9a9b3d8-511e-4640-9b2d-15fbd53f7209/api/v1/remote_write"
    otlpGrpcEndpoint                = "0.0.0.0:4317"
    otlpHttpEndpoint                = "0.0.0.0:4318"
  }

  ssm_param_value = yamlencode(
    templatefile("${path.module}/configs/config.yaml", local.default_otel_values)
  )

  container_def_default_values = {
    container_name = "adot_new"
    otel_image_ver = "v0.31.0"
    aws_region     = data.aws_region.current.name
  }

  container_definitions = templatefile("${path.module}/task_definitions/otel_collector.json", local.container_def_default_values)

}
