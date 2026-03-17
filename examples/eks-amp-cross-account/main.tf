locals {
  amp_workspace_alias = var.monitoring.amp_workspace_alias
}

###########################################################################
#               EKS Monitoring for cluster one                            #
###########################################################################
module "eks_monitoring_one" {
  source = "../..//modules/eks-monitoring"

  providers = {
    aws     = aws.eks_cluster_one
    helm    = helm.eks_cluster_one
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.cluster_one.name
  eks_oidc_provider_arn = var.cluster_one_oidc_provider_arn

  # Use the central AMP workspace
  create_amp_workspace            = false
  managed_prometheus_workspace_id = module.managed_service_prometheus.workspace_id

  # Dashboards provisioned once from cluster one
  enable_dashboards = true

  # Disable rules — managed centrally or from one cluster only
  enable_alerting_rules  = false
  enable_recording_rules = false

  enable_tracing = true
  enable_logs    = true

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }
}


###########################################################################
#               EKS Monitoring for cluster two                            #
###########################################################################
module "eks_monitoring_two" {
  source = "../..//modules/eks-monitoring"

  providers = {
    aws     = aws.eks_cluster_two
    helm    = helm.eks_cluster_two
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.cluster_two.name
  eks_oidc_provider_arn = var.cluster_two_oidc_provider_arn

  # Use the central AMP workspace
  create_amp_workspace            = false
  managed_prometheus_workspace_id = module.managed_service_prometheus.workspace_id

  # Skip dashboards — already provisioned from cluster one
  enable_dashboards = false

  # Disable rules — managed centrally or from one cluster only
  enable_alerting_rules  = false
  enable_recording_rules = false

  enable_tracing = true
  enable_logs    = true

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }
}

###########################################################################
#                  AMP and Grafana resources                              #
###########################################################################

resource "aws_grafana_workspace_api_key" "key" {
  provider        = aws.central_monitoring
  key_name        = "terraform-api-key"
  key_role        = "ADMIN"
  seconds_to_live = 86400
  workspace_id    = var.monitoring.managed_grafana_id
}

module "managed_service_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "2.2.2"
  providers = {
    aws = aws.central_monitoring
  }

  workspace_alias = local.amp_workspace_alias
}
