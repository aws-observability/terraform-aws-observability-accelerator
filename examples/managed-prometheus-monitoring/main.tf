provider "aws" {
  region = local.region
}

provider "grafana" {
  url  = local.amg_ws_endpoint
  auth = var.grafana_api_key
}

data "aws_grafana_workspace" "this" {
  count        = var.managed_grafana_workspace_id == "" ? 0 : 1
  workspace_id = var.managed_grafana_workspace_id
}

locals {
  region          = var.aws_region
  amg_ws_endpoint = "https://${data.aws_grafana_workspace.this[0].endpoint}"
}

resource "grafana_folder" "this" {
  title = "Amazon Managed Prometheus monitoring dashboards"
}

module "managed_prometheus_monitoring" {
  source                           = "../../modules/managed-prometheus-monitoring"
  dashboards_folder_id             = resource.grafana_folder.this.id
  aws_region                       = local.region
  managed_prometheus_workspace_ids = var.managed_prometheus_workspace_ids
}
