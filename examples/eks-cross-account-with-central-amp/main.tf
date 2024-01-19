locals {
  amp_workspace_alias = var.monitoring.amp_workspace_alias
}

###########################################################################
#               EKS Monitoring Addon for cluster one                      #
###########################################################################
module "eks_monitoring_one" {
  source = "../..//modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"
  providers = {
    aws        = aws.eks_cluster_one
    helm       = helm.eks_cluster_one
    kubernetes = kubernetes.eks_cluster_one
    kubectl    = kubectl.eks_cluster_one
  }

  eks_cluster_id          = var.cluster_one.name
  enable_amazon_eks_adot  = true
  enable_cert_manager     = true
  enable_fluxcd           = true
  enable_external_secrets = true
  enable_dashboards       = true
  enable_java             = true
  enable_nginx            = true
  enable_node_exporter    = true

  # Additional dashboards
  enable_apiserver_monitoring  = true
  enable_adotcollector_metrics = true

  # Set to false for cross-cluster observability
  enable_alerting_rules  = false
  enable_recording_rules = false

  grafana_api_key         = aws_grafana_workspace_api_key.key.key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = "https://${data.aws_grafana_workspace.this.endpoint}"


  # prevents the module to create a workspace
  enable_managed_prometheus = false

  managed_prometheus_workspace_id       = module.managed_service_prometheus.workspace_id
  managed_prometheus_workspace_endpoint = module.managed_service_prometheus.workspace_prometheus_endpoint
  managed_prometheus_workspace_region   = var.cluster_one.region
  managed_prometheus_cross_account_role = aws_iam_role.cross_account_amp_role.arn
  irsa_iam_additional_policies          = [aws_iam_policy.irsa_assume_role_policy_one.arn]

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  enable_logs = true
}


###########################################################################
#               EKS Monitoring Addon for cluster two                      #
###########################################################################

module "eks_monitoring_two" {
  source = "../..//modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"
  providers = {
    aws        = aws.eks_cluster_two
    helm       = helm.eks_cluster_two
    kubernetes = kubernetes.eks_cluster_two
    kubectl    = kubectl.eks_cluster_two
  }

  eks_cluster_id          = var.cluster_two.name
  enable_amazon_eks_adot  = true
  enable_cert_manager     = true
  enable_fluxcd           = false
  enable_external_secrets = false
  enable_dashboards       = false
  enable_node_exporter    = true

  # Additional dashboards
  enable_apiserver_monitoring  = false
  enable_adotcollector_metrics = false

  # Set to false for cross-cluster observability
  enable_alerting_rules  = false
  enable_recording_rules = false

  grafana_api_key         = aws_grafana_workspace_api_key.key.key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = "https://${data.aws_grafana_workspace.this.endpoint}"

  # prevents the module to create a workspace
  enable_managed_prometheus = false

  managed_prometheus_workspace_id       = module.managed_service_prometheus.workspace_id
  managed_prometheus_workspace_endpoint = module.managed_service_prometheus.workspace_prometheus_endpoint
  managed_prometheus_workspace_region   = var.cluster_two.region

  managed_prometheus_cross_account_role = aws_iam_role.cross_account_amp_role.arn
  irsa_iam_additional_policies          = [aws_iam_policy.irsa_assume_role_policy_two.arn]

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  enable_logs = true
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
