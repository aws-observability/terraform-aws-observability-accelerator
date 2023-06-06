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
    enable_alerting_rules  = var.java_config.enable_alerting_rules
    enable_recording_rules = var.java_config.enable_recording_rules
    enable_dashboards      = var.java_config.enable_dashboards

    scrape_sample_limit = var.java_config.scrape_sample_limit

    flux_name                 = var.java_config.flux_name
    flux_gitrepository_url    = var.java_config.flux_gitrepository_url
    flux_gitrepository_branch = var.java_config.flux_gitrepository_branch
    flux_kustomization_path   = var.java_config.flux_kustomization_path

    managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
    managed_prometheus_workspace_region   = var.managed_prometheus_workspace_region
    managed_prometheus_workspace_endpoint = var.managed_prometheus_workspace_endpoint
    prometheus_metrics_endpoint           = var.java_config.prometheus_metrics_endpoint

    grafana_url           = var.grafana_url
    grafana_dashboard_url = var.java_config.grafana_dashboard_url
  }

  nginx_pattern_config = {
    enable_alerting_rules  = var.nginx_config.enable_alerting_rules
    enable_recording_rules = var.nginx_config.enable_recording_rules
    enable_dashboards      = var.java_config.enable_dashboards

    scrape_sample_limit = var.nginx_config.scrape_sample_limit

    flux_name                 = var.nginx_config.flux_name
    flux_gitrepository_url    = var.nginx_config.flux_gitrepository_url
    flux_gitrepository_branch = var.nginx_config.flux_gitrepository_branch
    flux_kustomization_path   = var.nginx_config.flux_kustomization_path

    managed_prometheus_workspace_id       = var.managed_prometheus_workspace_id
    managed_prometheus_workspace_region   = var.managed_prometheus_workspace_region
    managed_prometheus_workspace_endpoint = var.managed_prometheus_workspace_endpoint
    prometheus_metrics_endpoint           = var.nginx_config.prometheus_metrics_endpoint

    grafana_url           = var.grafana_url
    grafana_dashboard_url = var.java_config.grafana_dashboard_url
  }
}
