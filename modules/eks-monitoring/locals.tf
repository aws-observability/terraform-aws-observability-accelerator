data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}

locals {
  name      = "adot-collector-kubeprometheus"
  namespace = try(var.helm_config.namespace, local.name)

  eks_oidc_issuer_url  = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = data.aws_eks_cluster.eks_cluster.endpoint
  eks_cluster_version  = data.aws_eks_cluster.eks_cluster.version

  context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = local.eks_cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }

  java_pattern_config = {
    # disabled if options from module are disabled, by default
    # can be overriden by providing a config
    enable_alerting_rules  = var.enable_alerting_rules
    enable_recording_rules = var.enable_recording_rules
    enable_dashboards      = var.enable_dashboards # disable flux kustomization if dashboards are disabled

    scrape_sample_limit = 1000

    flux_gitrepository_name   = "aws-observability-accelerator"
    flux_gitrepository_url    = "https://github.com/aws-observability/aws-observability-accelerator"
    flux_gitrepository_branch = "main"
    flux_kustomization_name   = "grafana-dashboards-java"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/java"

    managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
    managed_prometheus_workspace_region   = var.managed_prometheus_workspace_region
    managed_prometheus_workspace_endpoint = var.managed_prometheus_workspace_endpoint
    prometheus_metrics_endpoint           = "/metrics"

    grafana_url           = var.grafana_url
    grafana_dashboard_url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/java/default.json"
  }

  nginx_pattern_config = {
    # disabled if options from module are disabled, by default
    # can be overriden by providing a config
    enable_alerting_rules  = var.enable_alerting_rules
    enable_recording_rules = var.enable_recording_rules
    enable_dashboards      = var.enable_dashboards

    scrape_sample_limit = 1000

    flux_gitrepository_name   = "aws-observability-accelerator"
    flux_gitrepository_url    = "https://github.com/aws-observability/aws-observability-accelerator"
    flux_gitrepository_branch = "main"
    flux_kustomization_name   = "grafana-dashboards-nginx"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/nginx"

    managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
    managed_prometheus_workspace_region   = var.managed_prometheus_workspace_region
    managed_prometheus_workspace_endpoint = var.managed_prometheus_workspace_endpoint
    prometheus_metrics_endpoint           = "/metrics"

    grafana_url           = var.grafana_url
    grafana_dashboard_url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/nginx/nginx.json"
  }

  istio_pattern_config = {
    # disabled if options from module are disabled, by default
    # can be overriden by providing a config
    enable_alerting_rules  = var.enable_alerting_rules
    enable_recording_rules = var.enable_recording_rules
    enable_dashboards      = var.enable_dashboards

    scrape_sample_limit = 1000

    flux_gitrepository_name   = "aws-observability-accelerator"
    flux_gitrepository_url    = "https://github.com/aws-observability/aws-observability-accelerator"
    flux_gitrepository_branch = "main"
    flux_kustomization_name   = "grafana-dashboards-istio"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/istio"

    managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
    managed_prometheus_workspace_region   = var.managed_prometheus_workspace_region
    managed_prometheus_workspace_endpoint = var.managed_prometheus_workspace_endpoint
    prometheus_metrics_endpoint           = "/metrics"

    grafana_url                             = var.grafana_url
    grafana_istio_cp_dashboard_url          = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/istio/istio-control-plane-dashboard.json"
    grafana_istio_mesh_dashboard_url        = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/istio/istio-mesh-dashboard.json"
    grafana_istio_performance_dashboard_url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/istio/istio-performance-dashboard.json"
    grafana_istio_service_dashboard_url     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/main/artifacts/grafana-dashboards/eks/istio/istio-service-dashboard.json"
  }

}
