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

    flux_gitrepository_name   = var.flux_gitrepository_name
    flux_gitrepository_url    = var.flux_gitrepository_url
    flux_gitrepository_branch = var.flux_gitrepository_branch
    flux_kustomization_name   = "grafana-dashboards-java"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/java"

    managed_prometheus_workspace_id = var.managed_prometheus_workspace_id
    prometheus_metrics_endpoint     = "/metrics"

    grafana_dashboard_url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/java/default.json"
  }

  nginx_pattern_config = {
    # disabled if options from module are disabled, by default
    # can be overriden by providing a config
    enable_alerting_rules  = var.enable_alerting_rules
    enable_recording_rules = var.enable_recording_rules
    enable_dashboards      = var.enable_dashboards

    scrape_sample_limit = 1000

    flux_gitrepository_name   = var.flux_gitrepository_name
    flux_gitrepository_url    = var.flux_gitrepository_url
    flux_gitrepository_branch = var.flux_gitrepository_branch
    flux_kustomization_name   = "grafana-dashboards-nginx"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/nginx"

    managed_prometheus_workspace_id = var.managed_prometheus_workspace_id
    prometheus_metrics_endpoint     = "/metrics"

    grafana_dashboard_url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/nginx/nginx.json"
  }

  istio_pattern_config = {
    # disabled if options from module are disabled, by default
    # can be overriden by providing a config
    enable_alerting_rules  = var.enable_alerting_rules
    enable_recording_rules = var.enable_recording_rules
    enable_dashboards      = var.enable_dashboards

    scrape_sample_limit = 1000

    flux_gitrepository_name   = var.flux_gitrepository_name
    flux_gitrepository_url    = var.flux_gitrepository_url
    flux_gitrepository_branch = var.flux_gitrepository_branch
    flux_kustomization_name   = "grafana-dashboards-istio"
    flux_kustomization_path   = "./artifacts/grafana-operator-manifests/eks/istio"

    managed_prometheus_workspace_id = var.managed_prometheus_workspace_id
    prometheus_metrics_endpoint     = "/metrics"

    dashboards = {
      cp          = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/istio/istio-control-plane-dashboard.json"
      mesh        = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/istio/istio-mesh-dashboard.json"
      performance = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/istio/istio-performance-dashboard.json"
      service     = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/istio/istio-service-dashboard.json"
    }
  }

  apiserver_monitoring_config = {
    # can be overriden by providing a config
    flux_gitrepository_name   = try(var.apiserver_monitoring_config.flux_gitrepository_name, var.flux_gitrepository_name)
    flux_gitrepository_url    = try(var.apiserver_monitoring_config.flux_gitrepository_url, var.flux_gitrepository_url)
    flux_gitrepository_branch = try(var.apiserver_monitoring_config.flux_gitrepository_branch, var.flux_gitrepository_branch)
    flux_kustomization_name   = try(var.apiserver_monitoring_config.flux_kustomization_name, "grafana-dashboards-apiserver")
    flux_kustomization_path   = try(var.apiserver_monitoring_config.flux_kustomization_path, "./artifacts/grafana-operator-manifests/eks/apiserver")

    dashboards = {
      basic           = try(var.apiserver_monitoring_config.dashboards.basic, "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/apiserver/apiserver-basic.json")
      advanced        = try(var.apiserver_monitoring_config.dashboards.advanced, "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/apiserver/apiserver-advanced.json")
      troubleshooting = try(var.apiserver_monitoring_config.dashboards.troubleshooting, "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/apiserver/apiserver-troubleshooting.json")
    }
  }

  adothealth_monitoring_config = {
    # can be overriden by providing a config
    flux_gitrepository_name   = try(var.adothealth_monitoring_config.flux_gitrepository_name, var.flux_gitrepository_name)
    flux_gitrepository_url    = try(var.adothealth_monitoring_config.flux_gitrepository_url, var.flux_gitrepository_url)
    flux_gitrepository_branch = try(var.adothealth_monitoring_config.flux_gitrepository_branch, var.flux_gitrepository_branch)
    flux_kustomization_name   = try(var.adothealth_monitoring_config.flux_kustomization_name, "grafana-dashboards-adothealth")
    flux_kustomization_path   = try(var.adothealth_monitoring_config.flux_kustomization_path, "./artifacts/grafana-operator-manifests/eks/adot")

    dashboards = {
      health = try(var.adothealth_monitoring_config.dashboards.health, "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/adot/adothealth.json")
    }
  }

  kubeproxy_monitoring_config = {
    # can be overriden by providing a config
    flux_gitrepository_name   = try(var.kubeproxy_monitoring_config.flux_gitrepository_name, var.flux_gitrepository_name)
    flux_gitrepository_url    = try(var.kubeproxy_monitoring_config.flux_gitrepository_url, var.flux_gitrepository_url)
    flux_gitrepository_branch = try(var.kubeproxy_monitoring_config.flux_gitrepository_branch, var.flux_gitrepository_branch)
    flux_kustomization_name   = try(var.kubeproxy_monitoring_config.flux_kustomization_name, "grafana-dashboards-kubeproxy")
    flux_kustomization_path   = try(var.kubeproxy_monitoring_config.flux_kustomization_path, "./artifacts/grafana-operator-manifests/eks/kube-proxy")

    dashboards = {
      default = try(var.kubeproxy_monitoring_config.dashboards.default, "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.2.0/artifacts/grafana-dashboards/eks/kube-proxy/kube-proxy.json")
    }
  }
}
