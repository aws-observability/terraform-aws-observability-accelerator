locals {
  name     = "aws-observability-accelerator-cloudwatch"
  amp_list = toset(split(",", var.managed_prometheus_workspace_id))
}
