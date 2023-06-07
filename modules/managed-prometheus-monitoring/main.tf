provider "aws" {
  region = "us-east-1"
  alias  = "billing_region"
}

locals {
  name     = "aws-observability-accelerator-cloudwatch"
  amp_list = toset(split(",", var.managed_prometheus_workspace_ids))
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = local.name

  # Giving priority to Managed Prometheus datasources
  is_default = false
  json_data {
    default_region  = var.aws_region
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = var.aws_region
  }
}

data "http" "dashboard" {
  url = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/a72787328e493c4628680487e3c885fc395d1c56/artifacts/grafana-dashboards/amp/amp-dashboard.json"

  request_headers = {
    Accept = "application/json"
  }
}

resource "grafana_dashboard" "this" {
  folder      = var.dashboards_folder_id
  config_json = data.http.dashboard.response_body
}

module "billing" {
  source = "./billing"
  providers = {
    aws = aws.billing_region
  }
}
