module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile     = "managed-metrics"
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  # AMP Managed Collector settings
  scraper_subnet_ids         = var.scraper_subnet_ids
  scraper_security_group_ids = var.scraper_security_group_ids

  # Create a new AMP workspace
  create_amp_workspace = true

  # Dashboards
  enable_dashboards = true

  tags = var.tags
}
