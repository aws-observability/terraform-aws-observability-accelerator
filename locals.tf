data "aws_region" "current" {}

data "aws_grafana_workspace" "this" {
  count        = var.managed_grafana_workspace_id == "" ? 0 : 1
  workspace_id = var.managed_grafana_workspace_id
}

locals {
  # if region is not passed, we assume the current one
  amp_ws_region   = coalesce(var.managed_prometheus_workspace_region, data.aws_region.current.name)
  amp_ws_id       = var.enable_managed_prometheus ? aws_prometheus_workspace.this[0].id : var.managed_prometheus_workspace_id
  amp_ws_endpoint = "https://aps-workspaces.${local.amp_ws_region}.amazonaws.com/workspaces/${local.amp_ws_id}/"

  # if grafana_workspace_id is supplied, we infer the endpoint from
  # computed region, else we create a new workspace
  amg_ws_endpoint = var.managed_grafana_workspace_id == "" ? "https://${module.managed_grafana[0].workspace_endpoint}" : "https://${data.aws_grafana_workspace.this[0].endpoint}"
  amg_ws_id       = var.managed_grafana_workspace_id == "" ? split(".", module.managed_grafana[0].workspace_endpoint)[0] : var.managed_grafana_workspace_id

  name = "aws-observability-accelerator"
}
