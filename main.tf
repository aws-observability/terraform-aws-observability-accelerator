
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


module "java" {
  count  = var.enable_java ? 1 : 0
  source = "./modules/workloads/java"

  addon_context = local.context

  amp_endpoint = var.create_managed_prometheus_workspace ? aws_prometheus_workspace.this[0].prometheus_endpoint : var.managed_prometheus_endpoint
  amp_id       = var.create_managed_prometheus_workspace ? aws_prometheus_workspace.this[0].id : var.managed_prometheus_id

  # if region is not passed, we assume the current one
  amp_region = try(var.managed_prometheus_region, local.context.aws_region_name)

  depends_on = [
    module.operator
  ]
}
