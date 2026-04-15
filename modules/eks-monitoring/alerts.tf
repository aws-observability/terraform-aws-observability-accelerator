#--------------------------------------------------------------
# Prometheus Alerting Rules (AMP flavor)
#--------------------------------------------------------------

locals {
  default_alerting_rules = <<-YAML
    groups:
      - name: accelerator-v2-alerting-rules
        rules:
          - alert: NodeNotReady
            expr: kube_node_status_condition{condition="Ready",status="true"} == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Node {{ $labels.node }} is not ready"
          - alert: KubeletDown
            expr: up{job="kubelet"} == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubelet on {{ $labels.instance }} is down"
          - alert: PodCrashLooping
            expr: rate(kube_pod_container_status_restarts_total[15m]) * 60 * 5 > 0
            for: 15m
            labels:
              severity: warning
            annotations:
              summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping"
          - alert: HighNodeCPU
            expr: node:node_cpu_utilisation:avg1m > 0.9
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "Node {{ $labels.node }} CPU utilisation above 90%"
          - alert: HighNodeMemory
            expr: node:node_memory_utilisation:ratio > 0.9
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "Node {{ $labels.node }} memory utilisation above 90%"
  YAML

  alerting_rules_yaml = var.custom_alerting_rules != "" ? "${local.default_alerting_rules}\n${var.custom_alerting_rules}" : local.default_alerting_rules
}

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = local.is_amp_flavor && var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-v2-alerting-rules"
  workspace_id = local.amp_workspace_id
  data         = local.alerting_rules_yaml
}
