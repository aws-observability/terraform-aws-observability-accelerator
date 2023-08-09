# SSM Parameter
resource "aws_ssm_parameter" "adot-config" {
  name        = "/observability_aws/otel_collector_conf"
  description = "SSM parameter for aws-observability-accelerator/otel-collector-config"
  type        = "String"
  value       = yamlencode(file("configs/config.yaml"))
}

############################################
# Managed Grafana and Prometheus Module
############################################

module "managed_grafana_default" {
  source            = "terraform-aws-modules/managed-service-grafana/aws"
  name              = "${local.name}-default"
  associate_license = false
}

module "managed_prometheus_default" {
  source          = "terraform-aws-modules/managed-service-prometheus/aws"
  workspace_alias = "${local.name}-default"
}

###########################################
# Task Definition for ADOT ECS Prometheus
###########################################
resource "aws_ecs_task_definition" "adot_ecs_prometheus" {
  family                   = "adot_prometheus_td"
  task_role_arn            = var.taskRoleArn
  execution_role_arn       = var.executionRoleArn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = file("task_definitions/otel_collector.json")
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
