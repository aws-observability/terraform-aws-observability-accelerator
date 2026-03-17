#--------------------------------------------------------------
# Prometheus Recording Rules (AMP flavor)
#--------------------------------------------------------------

locals {
  default_recording_rules = <<-YAML
    groups:
      - name: accelerator-v2-recording-rules
        rules:
          - record: node:node_cpu_utilisation:avg1m
            expr: avg by (node) (rate(node_cpu_seconds_total{mode!="idle"}[1m]))
          - record: node:node_memory_utilisation:ratio
            expr: 1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
          - record: node:node_net_bytes_transmitted:sum_rate
            expr: sum by (node) (rate(node_network_transmit_bytes_total[1m]))
          - record: node:node_net_bytes_received:sum_rate
            expr: sum by (node) (rate(node_network_receive_bytes_total[1m]))
          - record: namespace:container_cpu_usage_seconds_total:sum_rate
            expr: sum by (namespace) (rate(container_cpu_usage_seconds_total{container!=""}[5m]))
          - record: namespace:container_memory_working_set_bytes:sum
            expr: sum by (namespace) (container_memory_working_set_bytes{container!=""})
  YAML

  recording_rules_yaml = var.custom_recording_rules != "" ? "${local.default_recording_rules}\n${var.custom_recording_rules}" : local.default_recording_rules
}

resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count = local.is_amp_flavor && var.enable_recording_rules ? 1 : 0

  name         = "accelerator-v2-recording-rules"
  workspace_id = local.amp_workspace_id
  data         = local.recording_rules_yaml
}
