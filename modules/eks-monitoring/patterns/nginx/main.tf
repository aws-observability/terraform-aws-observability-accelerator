resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-nginx-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
    - name: Nginx-HTTP-4xx-error-rate
      rules:
      - alert: metric:alerting_rule
        expr: sum(rate(nginx_http_requests_total{status=~"^4.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
        for: 1m
        labels:
         severity: critical
        annotations:
         summary: Nginx high HTTP 4xx error rate (instance {{ $labels.instance }})
         description: "Too many HTTP requests with status 4xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - name: Nginx-HTTP-5xx-error-rate
      rules:
      - alert: metric:alerting_rule
        expr: sum(rate(nginx_http_requests_total{status=~"^5.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
        for: 1m
        labels:
         severity: critical
        annotations:
         summary: Nginx high HTTP 5xx error rate (instance {{ $labels.instance }})
         description: "Too many HTTP requests with status 5xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - name: Nginx-high-latency
      rules:
      - alert: metric:alerting_rule
        expr: histogram_quantile(0.99, sum(rate(nginx_http_request_duration_seconds_bucket[2m])) by (host, node)) > 3
        for: 2m
        labels:
         severity: warning
        annotations:
         summary: Nginx latency high (instance {{ $labels.instance }})
         description: "Nginx p99 latency is higher than 3 seconds\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
EOF
}
resource "grafana_dashboard" "workloads" {
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/nginx.json")

}
