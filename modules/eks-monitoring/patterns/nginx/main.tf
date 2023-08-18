resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.pattern_config.enable_alerting_rules ? 1 : 0

  name         = "accelerator-nginx-alerting"
  workspace_id = var.pattern_config.managed_prometheus_workspace_id
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

resource "kubectl_manifest" "flux_kustomization" {
  count = var.pattern_config.enable_dashboards ? 1 : 0

  yaml_body = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: ${var.pattern_config.flux_kustomization_name}
  namespace: flux-system
spec:
  interval: 1m0s
  path: ${var.pattern_config.flux_kustomization_path}
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${var.pattern_config.flux_gitrepository_name}
  postBuild:
    substitute:
      GRAFANA_NGINX_DASH_URL: ${var.pattern_config.grafana_dashboard_url}
YAML
}
