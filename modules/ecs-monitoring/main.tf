# SSM Parameter for storing and distrivuting the ADOT config
resource "aws_ssm_parameter" "adot-config" {
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
  source            = "terraform-aws-modules/managed-service-grafana/aws"
  name              = "${local.name}-default"
  associate_license = false
}

#####################
## Commented this module, as AMP workspace is a pre-requiste for this solution.
## You can use this code to create a AMP workspace
#####################

# module "managed_prometheus_default" {
#   source          = "terraform-aws-modules/managed-service-prometheus/aws"
#   workspace_alias = "${local.name}-default"
# }

###########################################
# Task Definition for ADOT ECS Prometheus
###########################################
resource "aws_ecs_task_definition" "adot_ecs_prometheus" {
  family                   = "adot_prometheus_td"
  task_role_arn            = var.taskRoleArn
  execution_role_arn       = var.executionRoleArn
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
