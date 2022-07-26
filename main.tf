
# DONT create the resources
# VPC and supporting resources
# EKS and Managed node groups

#
//*
module "adot_operator" {
  source = "./modules/core/opentelemetry-operator"
  count  = var.enable_amazon_eks_adot ? 1 : 0

  enable_cert_manager = var.enable_cert_manager

  kubernetes_version = local.eks_cluster_version
  addon_context      = local.context
}
//*/

module "java" {
  source = "./modules/workloads/java"
}
