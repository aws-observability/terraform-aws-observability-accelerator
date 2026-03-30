provider "aws" {
  region = var.aws_region
}

locals {
  name        = "aws-observability-accelerator"
  description = "Amazon Managed Grafana workspace for ${local.name}"

  tags = {
    GithubRepo = "terraform-aws-observability-accelerator"
    GithubOrg  = "aws-observability"
  }
}

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.1"

  name                      = local.name
  associate_license         = false
  description               = local.description
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]
  grafana_version           = "10.4"

  configuration = jsonencode({
    unifiedAlerting = { enabled = true }
    plugins         = { pluginAdminEnabled = true }
  })

  create_iam_role                = true
  iam_role_name                  = local.name
  use_iam_role_name_prefix       = true
  iam_role_description           = local.description
  iam_role_path                  = "/grafana/"
  iam_role_force_detach_policies = true
  iam_role_max_session_duration  = 7200
  iam_role_tags                  = local.tags

  tags = local.tags
}

#--------------------------------------------------------------
# Service Account + Token (for Terraform-driven provisioning)
#--------------------------------------------------------------

resource "aws_grafana_workspace_service_account" "terraform" {
  name         = "terraform-provisioner"
  grafana_role = "ADMIN"
  workspace_id = module.managed_grafana.workspace_id
}

resource "aws_grafana_workspace_service_account_token" "terraform" {
  name               = "terraform-token"
  service_account_id = aws_grafana_workspace_service_account.terraform.service_account_id
  workspace_id       = module.managed_grafana.workspace_id
  seconds_to_live    = 2592000 # 30 days
}
