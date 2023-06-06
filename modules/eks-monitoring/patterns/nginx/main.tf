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


resource "kubectl_manifest" "flux_gitrepository" {
  yaml_body  = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: ${var.flux_name}
  namespace: flux-system
spec:
  interval: 5m0s
  url: ${var.flux_gitrepository_url}
  ref:
    branch: ${var.flux_gitrepository_branch}
YAML
  count      = var.enable_dashboards ? 1 : 0
}

resource "kubectl_manifest" "flux_kustomization" {
  yaml_body  = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: ${var.flux_name}
  namespace: flux-system
spec:
  interval: 1m0s
  path: ${var.flux_kustomization_path}
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${var.flux_name}
  postBuild:
    substitute:
      AMG_AWS_REGION: ${var.managed_prometheus_workspace_region}
      AMP_ENDPOINT_URL: ${var.managed_prometheus_workspace_endpoint}
      AMG_ENDPOINT_URL: ${var.grafana_url}
      GRAFANA_NGINX_DASH_URL: ${var.grafana_dashboard_url}
YAML
  count      = var.enable_dashboards ? 1 : 0
}
