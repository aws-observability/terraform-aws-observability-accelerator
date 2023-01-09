################################################################################################################################################
# Alerting rules ###############################################################################################################################
################################################################################################################################################

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-haproxy-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
    - name: HAProxy-high-HTTP-error-rate-backend
      rules:
        - alert: metric:alerting_rule
          annotations:
            summary: HAProxy high HTTP 4xx error rate backend
            description: Too many HTTP requests with status 4xx (> 5%) on backend {{ $labels.fqdn }}/{{ $labels.backend }}
          expr: ((sum by (proxy) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (proxy) (rate(haproxy_server_http_responses_total[1m]))) * 100) > 5
          labels:
            severity: critical
          for: 1m
    - name: HAProxy-high-HTTP-5xx-error-rate-server
      rules:
        - alert: metric:alerting_rule
          annotations:
            summary: HAProxy high HTTP 4xx error rate server
            description: Too many HTTP requests with status 4xx (> 5%) on server {{ $labels.server }}
          expr: ((sum by (server) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (server) (rate(haproxy_server_http_responses_total[1m]))) * 100) > 5
          labels:
            severity: critical
          for: 1m
EOF
}