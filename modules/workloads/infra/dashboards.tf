resource "grafana_dashboard" "alertmanager" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/alertmanager.json")
}

resource "grafana_dashboard" "workloads" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/workloads.json")
}

resource "grafana_dashboard" "scheduler" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/scheduler.json")
}

resource "grafana_dashboard" "proxy" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/proxy.json")
}

resource "grafana_dashboard" "prometheus" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/prometheus.json")
}

resource "grafana_dashboard" "podnetwork" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/pods-networking.json")
}

resource "grafana_dashboard" "pods" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/pods.json")
}

resource "grafana_dashboard" "pv" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/pesistentvolumes.json")
}

resource "grafana_dashboard" "nodes" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/nodes.json")
}

resource "grafana_dashboard" "necluster" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/nodeexpoter-use-cluster.json")
}

resource "grafana_dashboard" "nenodeuse" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/nodeexporter-use-node.json")
}

resource "grafana_dashboard" "nenode" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/nodeexporter-nodes.json")
}

resource "grafana_dashboard" "nwworload" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/networking-workloads.json")
}

resource "grafana_dashboard" "nsworkload" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/namespace-workloads.json")
}

resource "grafana_dashboard" "nspods" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/namespace-pods.json")
}

resource "grafana_dashboard" "nsnwworkload" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/namespace-nw-workloads.json")
}

resource "grafana_dashboard" "nsnw" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/namespace-networking.json")
}

resource "grafana_dashboard" "macos" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/macos.json")
}

resource "grafana_dashboard" "kubelet" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/kubelet.json")
}

resource "grafana_dashboard" "grafana" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/grafana.json")
}

resource "grafana_dashboard" "etcd" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/etcd.json")
}

resource "grafana_dashboard" "coredns" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/coredns.json")
}

resource "grafana_dashboard" "controller" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/controller.json")
}

resource "grafana_dashboard" "clusternw" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/cluster-networking.json")
}

resource "grafana_dashboard" "cluster" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/cluster.json")
}

resource "grafana_dashboard" "apis" {
  count       = var.config.enable_dashboards ? 1 : 0
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/apiserver.json")
}
