resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  name         = "accelerator-istio-rules"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: default-metric
    rules:
      - record: metric:recording_rule
        expr: avg(rate(container_cpu_usage_seconds_total[5m]))
EOF
}

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-istio-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: default-alert
    rules:
      - alert: metric:alerting_rule
        expr: jvm_memory_bytes_used{job="java", area="heap"} / jvm_memory_bytes_max * 100 > 80
        for: 1m
        labels:
            severity: warning
        annotations:
            summary: "JVM heap warning"
            description: "JVM heap of instance `{{$labels.instance}}` from application `{{$labels.application}}` is above 80% for one minute. (current=`{{$value}}%`)"
EOF
}

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

