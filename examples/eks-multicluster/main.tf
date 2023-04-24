module "aws_observability_accelerator" {
  source                              = "../../../terraform-aws-observability-accelerator"
  aws_region                          = var.primary_eks_cluster.aws_region
  enable_managed_prometheus           = false
  enable_alertmanager                 = true
  create_dashboard_folder             = true
  create_prometheus_data_source       = true
  grafana_api_key                     = var.grafana_api_key
  managed_prometheus_workspace_region = null
  managed_prometheus_workspace_id     = var.managed_prometheus_workspace_id
  managed_grafana_workspace_id        = var.managed_grafana_workspace_id

  providers = {
    aws = aws.primary
  }
}

module "primary_eks_cluster_monitoring" {
  source                 = "../../../terraform-aws-observability-accelerator//modules/eks-monitoring"
  eks_cluster_id         = var.primary_eks_cluster.id
  enable_amazon_eks_adot = true
  enable_cert_manager    = true
  enable_java            = true

  // This section of configuration results in actions performed on AMG and AMP; and it needs to be done just once
  // Hence, this in performed in conjunction with the primary EKS cluster
  enable_dashboards      = true
  enable_alerting_rules  = true
  enable_recording_rules = true

  grafana_api_key                       = var.grafana_api_key
  dashboards_folder_id                  = module.aws_observability_accelerator.grafana_dashboards_folder_id
  managed_prometheus_workspace_id       = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region

  java_config = {
    enable_alerting_rules  = true
    enable_recording_rules = true
    scrape_sample_limit    = 1
  }

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.primary
    kubernetes = kubernetes.primary
    helm       = helm.primary
    grafana    = grafana
  }

  depends_on = [
    module.aws_observability_accelerator
  ]
}

module "secondary_eks_cluster_monitoring" {
  source                 = "../../../terraform-aws-observability-accelerator//modules/eks-monitoring"
  eks_cluster_id         = var.secondary_eks_cluster.id
  enable_amazon_eks_adot = true
  enable_cert_manager    = true
  enable_java            = true

  // This section of configuration results in actions performed on AMG and AMP; and it needs to be done just once
  // Since performed in conjunction with the primary EKS cluster, we will skip them with secondart EKS cluster
  enable_dashboards      = false
  enable_alerting_rules  = false
  enable_recording_rules = false

  grafana_api_key                       = var.grafana_api_key
  dashboards_folder_id                  = module.aws_observability_accelerator.grafana_dashboards_folder_id
  managed_prometheus_workspace_id       = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region

  java_config = {
    enable_alerting_rules  = false // addressed by primary EKS cluster
    enable_recording_rules = false // addressed by primary EKS cluster
    scrape_sample_limit    = 1
  }

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.secondary
    kubernetes = kubernetes.secondary
    helm       = helm.secondary
    grafana    = grafana
  }

  depends_on = [
    module.aws_observability_accelerator
  ]
}
