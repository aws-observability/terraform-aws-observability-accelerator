locals {
  create_new_workspace            = var.managed_prometheus_workspace_id == "" ? true : false
  managed_prometheus_workspace_id = local.create_new_workspace ? module.managed_service_prometheus[0].workspace_id : var.managed_prometheus_workspace_id
}

module "eks_cluster_1_monitoring" {
  source = "../..//modules/eks-monitoring"

  providers = {
    aws     = aws.eks_cluster_1
    helm    = helm.eks_cluster_1
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.eks_cluster_1_id
  eks_oidc_provider_arn = var.eks_cluster_1_oidc_provider_arn

  # Use shared AMP workspace
  create_amp_workspace            = false
  managed_prometheus_workspace_id = local.managed_prometheus_workspace_id

  # Dashboards and rules provisioned from cluster 1 only
  enable_dashboards      = true
  enable_alerting_rules  = true
  enable_recording_rules = true

  enable_tracing = true
  enable_logs    = true

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }
}

module "eks_cluster_2_monitoring" {
  source = "../..//modules/eks-monitoring"

  providers = {
    aws     = aws.eks_cluster_2
    helm    = helm.eks_cluster_2
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.eks_cluster_2_id
  eks_oidc_provider_arn = var.eks_cluster_2_oidc_provider_arn

  # Use shared AMP workspace
  create_amp_workspace            = false
  managed_prometheus_workspace_id = local.managed_prometheus_workspace_id

  # Skip dashboards and rules — already provisioned from cluster 1
  enable_dashboards      = false
  enable_alerting_rules  = false
  enable_recording_rules = false

  enable_tracing = true
  enable_logs    = true

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }
}

module "managed_service_prometheus" {
  count   = local.create_new_workspace ? 1 : 0
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.2.2"
  providers = {
    aws = aws.eks_cluster_1
  }

  workspace_alias = "aws-observability-accelerator-multicluster"
}
