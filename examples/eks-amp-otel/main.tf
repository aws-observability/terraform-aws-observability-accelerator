module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  # Create a new AMP workspace
  create_amp_workspace = true

  # Enable all pipelines
  enable_tracing = true
  enable_logs    = true

  # Dashboards
  enable_dashboards = true

  tags = var.tags
}
