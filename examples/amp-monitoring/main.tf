provider "aws" {
  region = local.region
}

provider "aws" {
  region = "us-east-1"
  alias = "BillingProvider"
}

provider "grafana" {
  url  = local.amg_ws_endpoint
  auth = var.grafana_api_key
}

data "aws_grafana_workspace" "this" {
  count        = var.managed_grafana_workspace_id == "" ? 0 : 1
  workspace_id = var.managed_grafana_workspace_id
}

locals {
  region          = var.aws_region
  amg_ws_endpoint = var.managed_grafana_workspace_id == "" ? "https://${module.managed_grafana[0].workspace_endpoint}" : "https://${data.aws_grafana_workspace.this[0].endpoint}"
  amg_ws_id       = var.managed_grafana_workspace_id == "" ? split(".", module.managed_grafana[0].workspace_endpoint)[0] : var.managed_grafana_workspace_id
  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
  name = "aws-observability-accelerator"
}

module "managed_grafana" {
  count   = var.enable_managed_grafana ? 1 : 0
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.3"

  # Workspace
  name              = local.name
  stack_set_name    = local.name
  data_sources      = ["CLOUDWATCH"]
  associate_license = false

  tags = local.tags
}

resource "grafana_folder" "this" {
  title = "AMP Monitoring Dashboards"
}

output "grafana_dashboards_folder_id" {
  description = "Grafana folder ID for automatic dashboards. Required by workload modules"
  value       = grafana_folder.this.id
}

module "amp_monitor" {
  source                          = "../../modules/workloads/amp-monitoring"
  dashboards_folder_id            = resource.grafana_folder.this.id
  aws_region                      = local.region
  managed_prometheus_workspace_id = var.managed_prometheus_workspace_id
  depends_on = [
    resource.grafana_folder.this
  ]
}

module "billing" {
  source = "../../modules/Billing"
  providers = {
    aws = aws.BillingProvider
  }
}
