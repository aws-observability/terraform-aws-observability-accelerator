resource "aws_prometheus_workspace" "this" {
  count = var.enable_managed_prometheus ? 1 : 0

  alias = local.name
  tags  = var.tags
}

resource "aws_prometheus_alert_manager_definition" "this" {
  count = var.enable_alertmanager ? 1 : 0

  workspace_id = local.amp_ws_id

  definition = <<EOF
alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
EOF
}
