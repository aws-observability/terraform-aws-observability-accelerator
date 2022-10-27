resource "grafana_data_source" "cloudwatch" {
  type       = "cloudwatch"
  name       = local.name
  is_default = true
  json_data {
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = var.aws_region
  }
}

resource "grafana_dashboard" "this" {
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/amp-dashboard.json")
}
