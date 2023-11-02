# SSM Parameter for storing and distrivuting the ADOT config
resource "aws_ssm_parameter" "adot_config" {
  name        = "/terraform-aws-observability/otel_collector_config"
  description = "SSM parameter for aws-observability-accelerator/otel-collector-config"
  type        = "String"
  value       = local.ssm_param_value
  tier        = "Intelligent-Tiering"
}

############################################
# Managed Grafana and Prometheus Module
############################################

module "managed_grafana_default" {
  count = var.create_managed_grafana_ws ? 1 : 0

  source            = "terraform-aws-modules/managed-service-grafana/aws"
  version           = "2.1.0"
  name              = "${local.name}-default"
  associate_license = false
}

module "managed_prometheus_default" {
  count = var.create_managed_prometheus_ws ? 1 : 0

  source          = "terraform-aws-modules/managed-service-prometheus/aws"
  version         = "2.2.2"
  workspace_alias = "${local.name}-default"
}

###########################################
# Task Definition for ADOT ECS Prometheus
###########################################
resource "aws_ecs_task_definition" "adot_ecs_prometheus" {
  family                   = "adot_prometheus_td"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.ecs_adot_cpu
  memory                   = var.ecs_adot_mem
  container_definitions    = local.container_definitions
}

############################################
# ECS Service
############################################
resource "aws_ecs_service" "adot_ecs_prometheus" {
  name            = "adot_prometheus_svc"
  cluster         = var.aws_ecs_cluster_name
  task_definition = aws_ecs_task_definition.adot_ecs_prometheus.arn
  desired_count   = 1
}
