
#---------------------------------------------------------------
# Observability Resources
#---------------------------------------------------------------

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.3"

  # Workspace
  name              = local.name
  stack_set_name    = local.name
  data_sources      = ["PROMETHEUS"]
  associate_license = false

  # # Role associations
  # Pending https://github.com/hashicorp/terraform-provider-aws/issues/24166
  # role_associations = {
  #   "ADMIN" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  #   "EDITOR" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  # }

  tags = local.tags
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.managed_prometheus.workspace_prometheus_endpoint

  json_data {
    http_method     = "GET"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.region
  }
}

resource "grafana_folder" "this" {
  title = "Observability"
}

resource "grafana_dashboard" "this" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/default.json")
}

module "managed_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.1"

  workspace_alias = local.name

  alert_manager_definition = <<-EOT
  alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
  EOT

  rule_group_namespaces = {
    haproxy = {
      name = "haproxy_rules"
      data = <<-EOT
      groups:
        - name: obsa-haproxy-down-alert
          rules:
            - alert: HA_proxy_down
              expr: haproxy_up == 0
              for: 0m
              labels:
                severity: critical
              annotations:
                summary: HAProxy down (instance {{ $labels.instance }})
                description: "HAProxy down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: obsa-haproxy-http4xx-error-alert
          rules:
            - alert: Ha_proxy_High_Http4xx_ErrorRate_Backend
              expr: sum by (backend) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (backend) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
              for: 1m
              labels:
                severity: critical
              annotations:
                summary: HAProxy high HTTP 4xx error rate backend (instance {{ $labels.instance }})
                description: "Too many HTTP requests with status 4xx (> 5%) on backend {{ $labels.fqdn }}/{{ $labels.backend }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: obsa-haproxy-http5xx-error-alert
          rules:
            - alert: Ha_proxy_High_Http5xx_ErrorRate_Backend
              expr: sum by (backend) (rate(haproxy_server_http_responses_total{code="5xx"}[1m])) / sum by (backend) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
              for: 1m
              labels:
                severity: critical
              annotations:
                summary: HAProxy high HTTP 5xx error rate backend (instance {{ $labels.instance }})
                description: "Too many HTTP requests with status 5xx (> 5%) on backend {{ $labels.fqdn }}/{{ $labels.backend }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: obsa-haproxy-Http4xx-ErrorRate-Server-alert
          rules:
            - alert: Ha_proxy_High_Http4xx_ErrorRate_Server
              expr: sum by (server) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (server) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
              for: 1m
              labels:
                severity: critical
              annotations:
                summary: HAProxy high HTTP 4xx error rate server (instance {{ $labels.instance }})
                description: "Too many HTTP requests with status 4xx (> 5%) on server {{ $labels.server }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: obsa-haproxy-Http5xx-ErrorRate-Server-alert
          rules:
            - alert: Ha_proxy_High_Http5xx_ErrorRate_Server
              expr: sum by (server) (rate(haproxy_server_http_responses_total{code="5xx"}[1m])) / sum by (server) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
              for: 1m
              labels:
                severity: critical
              annotations:
                summary: HAProxy high HTTP 5xx error rate server (instance {{ $labels.instance }})
                description: "Too many HTTP requests with status 5xx (> 5%) on server {{ $labels.server }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
      EOT
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Sample Application
#---------------------------------------------------------------

# https://github.com/haproxy-ingress/charts/tree/master/haproxy-ingress
resource "helm_release" "haproxy_ingress" {
  namespace        = "haproxy-ingress"
  create_namespace = true

  name       = "haproxy-ingress"
  repository = "https://haproxy-ingress.github.io/charts"
  chart      = "haproxy-ingress"
  version    = "0.13.7"

  set {
    name  = "defaultBackend.enabled"
    value = true
  }

  set {
    name  = "controller.stats.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = 9101
    type  = "string"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = true
    type  = "string"
  }
}

