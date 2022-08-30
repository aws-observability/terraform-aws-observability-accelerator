module "operator" {
  source = "./modules/add-ons/adot-operator"

  enable_cert_manager = var.enable_cert_manager
  kubernetes_version  = local.eks_cluster_version
  addon_context       = local.context
}

resource "aws_prometheus_workspace" "this" {
  count = var.enable_managed_prometheus ? 1 : 0

  alias = local.name
  tags  = var.tags
}

resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.enable_alertmanager ? 1 : 0

  workspace_id = local.amp_ws_id

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

# dashboards
resource "grafana_folder" "this" {
  title = "Observability Accelerator Dashboards"
}
