data "aws_region" "current" {}

locals {
  taskRoleArn            = var.taskRoleArn
  executionRoleArn       = var.executionRoleArn
  region                 = data.aws_region.current.name
  name                   = "amg-ex-${replace(basename(path.cwd), "_", "-")}"
  description            = "AWS Managed Grafana service for ${local.name}"
  prometheus_ws_endpoint = module.managed_prometheus_default[0].workspace_prometheus_endpoint

  default_otel_values = {
    aws_region                      = data.aws_region.current.name
    cluster_name                    = var.aws_ecs_cluster_name
    cluster_region                  = data.aws_region.current.name
    refresh_interval                = "60s"
    ecs_metrics_collection_interval = "15s"
    amp_remote_write_ep             = "${local.prometheus_ws_endpoint}api/v1/remote_write"
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

  container_definitions = templatefile("${path.module}/task-definitions/otel_collector.json", local.container_def_default_values)

}
