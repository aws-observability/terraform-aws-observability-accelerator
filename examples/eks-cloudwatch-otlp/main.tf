locals {
  tags = {
    Example = "eks-cloudwatch-otlp"
  }
}

#--------------------------------------------------------------
# EKS Monitoring Module (CloudWatch OTLP profile)
#--------------------------------------------------------------

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile = "cloudwatch-otlp"
  eks_cluster_id    = var.eks_cluster_id

  # CloudWatch OTLP — defaults to regional endpoint if empty
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint

  # AMP not needed
  create_amp_workspace = false

  # Dashboards
  enable_dashboards = var.grafana_endpoint != "" ? true : false

  tags = local.tags
}
