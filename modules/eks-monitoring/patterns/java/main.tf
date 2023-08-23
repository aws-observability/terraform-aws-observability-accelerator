resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count = var.pattern_config.enable_recording_rules ? 1 : 0

  name         = "accelerator-java-rules"
  workspace_id = var.pattern_config.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: default-metric
    rules:
      - record: metric:recording_rule
        expr: avg(rate(container_cpu_usage_seconds_total[5m]))
EOF
}

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.pattern_config.enable_alerting_rules ? 1 : 0

  name         = "accelerator-java-alerting"
  workspace_id = var.pattern_config.managed_prometheus_workspace_id
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
      GRAFANA_JAVA_JMX_DASH_URL: ${var.pattern_config.grafana_dashboard_url}
YAML
}
