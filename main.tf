
# DONT create the resources
# VPC and supporting resources
# EKS and Managed node groups

# locals {
#   # if both adot and otel are enabled, just deploys adot
#   enable_otel = (var.enable_amazon_eks_adot && var.enable_opentelemetry_operator) ? false : var.enable_opentelemetry_operator

#   # if both adot and otel are disabled, just deploys adot
#   enable_adot = (!var.enable_amazon_eks_adot && !var.enable_opentelemetry_operator) ? true : var.enable_amazon_eks_adot

#   #possible side effects? maybe customer wants only dashboards?

# }

module "operator" {
  source = "./modules/core/opentelemetry-operator"

  enable_cert_manager = var.enable_cert_manager

  enable_amazon_eks_adot        = var.enable_amazon_eks_adot
  enable_opentelemetry_operator = var.enable_opentelemetry_operator

  kubernetes_version = local.eks_cluster_version
  addon_context      = local.context
}

resource "aws_prometheus_workspace" "this" {
  count = var.create_managed_prometheus_workspace ? 1 : 0

  alias = local.name
  tags  = var.tags
}


resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.enable_alertmanager ? 1 : 0

  workspace_id = local.amp_ws_id

  # TODO: support custom alert manager config
  definition = <<EOF
alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
EOF
}

module "java" {
  count  = var.enable_java ? 1 : 0
  source = "./modules/workloads/java"

  addon_context = local.context

  amp_endpoint = local.amp_ws_endpoint
  amp_id       = local.amp_ws_id
  amp_region   = local.amp_ws_region

  enable_recording_rules = var.enable_java_recording_rules

  depends_on = [
    module.operator
  ]
}
