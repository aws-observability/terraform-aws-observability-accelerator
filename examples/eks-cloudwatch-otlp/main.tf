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

  collector_profile      = "cloudwatch-otlp"
  eks_cluster_id         = var.eks_cluster_id
  cw_agent_addon_version = "v6.0.0-eksbuild.1"

  # OTLP gateway — deploys CWA as a Deployment accepting app telemetry
  enable_otlp_gateway = true

  # CloudWatch OTLP — defaults to regional endpoint if empty
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint

  # AMP not needed
  create_amp_workspace = false

  # Dashboards — uses default git raw URLs from the module
  enable_dashboards  = var.grafana_endpoint != "" ? true : false
  grafana_endpoint   = var.grafana_endpoint
  grafana_api_key    = var.grafana_api_key

  tags = local.tags
}
