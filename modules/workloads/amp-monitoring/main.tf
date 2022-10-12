resource "grafana_dashboard" "this" {
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/amp-dashboard.json")
}





