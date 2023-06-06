resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count        = var.enable_recording_rules ? 1 : 0
  name         = "accelerator-java-rules"
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

  name         = "accelerator-java-alerting"
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

resource "kubectl_manifest" "flux_gitrepository" {
  yaml_body = <<YAML
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
  count     = var.enable_dashboards ? 1 : 0
}

resource "kubectl_manifest" "flux_kustomization" {
  yaml_body = <<YAML
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
      GRAFANA_JAVA_JMX_DASH_URL: ${var.grafana_dashboard_url}
YAML
  count     = var.enable_dashboards ? 1 : 0
}
