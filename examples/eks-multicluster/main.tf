locals {
  create_new_workspace            = var.managed_prometheus_workspace_id == "" ? true : false
  managed_prometheus_workspace_id = local.create_new_workspace ? module.managed_service_prometheus[0].workspace_id : var.managed_prometheus_workspace_id
}
module "eks_cluster_1_monitoring" {
  source                 = "../..//modules/eks-monitoring"
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

  # Additional dashboards
  enable_apiserver_monitoring  = true
  enable_adotcollector_metrics = true

  grafana_api_key = var.grafana_api_key
  grafana_url     = "https://${data.aws_grafana_workspace.this.endpoint}"

  # prevents the module to create a workspace
  enable_managed_prometheus = false

  managed_prometheus_workspace_id       = local.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = data.aws_prometheus_workspace.this.prometheus_endpoint
  managed_prometheus_workspace_region   = var.eks_cluster_1_region

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.eks_cluster_1
    kubernetes = kubernetes.eks_cluster_1
    helm       = helm.eks_cluster_1
  }
}

module "eks_cluster_2_monitoring" {
  source                 = "../..//modules/eks-monitoring"
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

  # Disable additional dashboards
  enable_apiserver_monitoring  = false
  enable_adotcollector_metrics = false

  # prevents the module to create a workspace
  enable_managed_prometheus = false

  managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = data.aws_prometheus_workspace.this.prometheus_endpoint
  managed_prometheus_workspace_region   = var.eks_cluster_1_region

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
    scrape_sample_limit    = 2000
  }

  providers = {
    aws        = aws.eks_cluster_2
    kubernetes = kubernetes.eks_cluster_2
    helm       = helm.eks_cluster_2
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
