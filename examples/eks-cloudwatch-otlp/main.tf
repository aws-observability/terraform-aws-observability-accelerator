module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile     = "cloudwatch-otlp"
  eks_cluster_id        = var.eks_cluster_id

  # CloudWatch OTLP endpoints
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint
  cloudwatch_log_group        = var.cloudwatch_log_group
  cloudwatch_log_stream       = var.cloudwatch_log_stream

  # AMP workspace not needed for CloudWatch flavor
  create_amp_workspace = false

  # Dashboards — Grafana provider configured above
  enable_dashboards = true

  tags = var.tags
}
