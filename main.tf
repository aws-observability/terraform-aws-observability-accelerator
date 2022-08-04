module "operator" {
  source = "./modules/core/opentelemetry-operator"

  enable_cert_manager = var.enable_cert_manager

  enable_amazon_eks_adot        = var.enable_amazon_eks_adot
  enable_opentelemetry_operator = var.enable_opentelemetry_operator

  kubernetes_version = local.eks_cluster_version
  addon_context      = local.context
}

resource "aws_prometheus_workspace" "this" {
  count = var.enable_managed_prometheus ? 1 : 0

  alias = local.name
  tags  = var.tags
}


resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.enable_alertmanager ? 1 : 0

  workspace_id = local.amp_ws_id

  # TODO: support custom alert manager config
  definition = <<EOF
alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
EOF
}

module "managed_grafana" {
  count   = var.enable_managed_grafana ? 1 : 0
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.3"

  # Workspace
  name              = local.name
  stack_set_name    = local.name
  data_sources      = ["PROMETHEUS"]
  associate_license = false

  tags = var.tags
}

provider "grafana" {
  url  = local.amg_ws_endpoint
  auth = var.grafana_api_key
}

resource "grafana_data_source" "amp" {
  type       = "prometheus"
  name       = local.name
  is_default = true
  url        = local.amp_ws_endpoint
  json_data {
    http_method     = "GET"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.amp_ws_region
  }
}

module "java" {
  count  = var.enable_java ? 1 : 0
  source = "./modules/workloads/java"

  addon_context = local.context

  amp_endpoint = local.amp_ws_endpoint
  amp_id       = local.amp_ws_id
  amp_region   = local.amp_ws_region

  enable_recording_rules = var.enable_java_recording_rules

  depends_on = [
    module.operator
  ]
}

module "infra" {
  count  = var.enable_infra_metrics ? 1 : 0
  source = "./modules/workloads/kube-prometheus"

  addon_context = local.context

  amp_endpoint = local.amp_ws_endpoint
  amp_id       = local.amp_ws_id
  amp_region   = local.amp_ws_region

  config = var.infra_metrics_config


  # enable_kube_state_metrics = var.infra_metrics_config.enable_kube_state_metrics
  # kms_create_namespace      = var.infra_metrics_config.kms_create_namespace
  # ksm_k8s_namespace         = var.infra_metrics_config.ksm_k8s_namespace
  # ksm_helm_chart_name       = var.infra_metrics_config.ksm_helm_chart_name
  # ksm_helm_chart_version    = var.infra_metrics_config.ksm_helm_chart_version
  # ksm_helm_release_name     = var.infra_metrics_config.ksm_helm_release_name
  # ksm_helm_repo_url         = var.infra_metrics_config.ksm_helm_repo_url
  # ksm_helm_settings         = var.infra_metrics_config.ksm_helm_settings
  # ksm_helm_values           = var.infra_metrics_config.ksm_helm_values

  # enable_node_exporter  = var.infra_metrics_config.enable_node_exporter
  # ne_create_namespace   = var.infra_metrics_config.ne_create_namespace
  # ne_helm_chart_name    = var.infra_metrics_config.ne_helm_chart_name
  # ne_helm_chart_version = var.infra_metrics_config.ne_helm_chart_version
  # ne_helm_release_name  = var.infra_metrics_config.ne_helm_release_name
  # ne_helm_repo_url      = var.infra_metrics_config.ne_helm_repo_url
  # ne_helm_settings      = var.infra_metrics_config.ksm_helm_settings
  # ne_helm_values        = var.infra_metrics_config.ksm_helm_values

  depends_on = [
    module.operator
  ]

}
