module "aws_observability_accelerator" {
  source                              = "../../../terraform-aws-observability-accelerator"
  aws_region                          = var.eks_cluster_1_region
  enable_managed_prometheus           = false
  enable_alertmanager                 = true
  grafana_api_key                     = var.grafana_api_key
  managed_prometheus_workspace_region = null
  managed_prometheus_workspace_id     = var.managed_prometheus_workspace_id
  managed_grafana_workspace_id        = var.managed_grafana_workspace_id

  providers = {
    aws = aws.eks_cluster_1
  }
}

module "eks_cluster_1_monitoring" {
  source                 = "../../../terraform-aws-observability-accelerator//modules/eks-monitoring"
  eks_cluster_id         = var.eks_cluster_1_id
  enable_amazon_eks_adot = true
  enable_cert_manager    = true
  enable_java            = true

  # This configuration section results in actions performed on AMG and AMP; and it needs to be done just once
  # And hence, this in performed in conjunction with the setup of the eks_cluster_1 EKS cluster
  enable_dashboards       = true
  enable_external_secrets = true
  enable_fluxcd           = true
  enable_alerting_rules   = true
  enable_recording_rules  = true

  grafana_api_key                       = var.grafana_api_key
  managed_prometheus_workspace_id       = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region
  grafana_url                           = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.eks_cluster_1
    kubernetes = kubernetes.eks_cluster_1
    helm       = helm.eks_cluster_1
    grafana    = grafana
  }

  depends_on = [
    module.aws_observability_accelerator
  ]
}

module "eks_cluster_2_monitoring" {
  source                 = "../../../terraform-aws-observability-accelerator//modules/eks-monitoring"
  eks_cluster_id         = var.eks_cluster_2_id
  enable_amazon_eks_adot = true
  enable_cert_manager    = true
  enable_java            = true

  # Since the following were enabled in conjunction with the set up of the
  # eks_cluster_1 EKS cluster, we will skip them with the eks_cluster_2 EKS cluster
  enable_dashboards       = false
  enable_external_secrets = false
  enable_fluxcd           = false
  enable_alerting_rules   = false
  enable_recording_rules  = false

  managed_prometheus_workspace_id       = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region
  grafana_url                           = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.eks_cluster_2
    kubernetes = kubernetes.eks_cluster_2
    helm       = helm.eks_cluster_2
    grafana    = grafana
  }

  depends_on = [
    module.aws_observability_accelerator
  ]
}
