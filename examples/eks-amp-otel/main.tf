module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.eks_cluster_id

  # Create a new AMP workspace
  create_amp_workspace = true

  # Enable all pipelines
  enable_tracing = true
  enable_logs    = true

  # Dashboards
  enable_dashboards = true

  tags = var.tags
}
