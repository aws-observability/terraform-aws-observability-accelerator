resource "grafana_dashboard" "cluster" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/cluster.json")
}

resource "grafana_dashboard" "istiomeshdashboard" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/istio-mesh-dashboard.json")
}

resource "grafana_dashboard" "istioservicedashboard" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/istio-service-dashboard.json")
}


resource "grafana_dashboard" "istiocontrolplanedashboard" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/istio-control-plane-dashboard.json")
}

resource "grafana_dashboard" "istioperformancedashboard" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/istio-performance-dashboard.json")
}

resource "grafana_dashboard" "workloads" {
  count       = var.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/workloads.json")
}
