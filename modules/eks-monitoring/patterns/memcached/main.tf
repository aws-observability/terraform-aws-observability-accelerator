resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-memcached-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: memcached-default
    rules:
      - alert:  memcached-down
        expr: memcached_up == 0
        for: 0m
        labels:
            severity: critical
        annotations:
            summary: memcached down (instance {{ $labels.instance }})
            description: "memcached instance is down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
EOF
}

resource "grafana_dashboard" "this" {
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/default.json")
}
