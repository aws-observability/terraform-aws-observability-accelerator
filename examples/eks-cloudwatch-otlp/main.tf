locals {
  name = "eks-cw-otlp-${var.eks_cluster_id}"

  tags = merge(var.tags, {
    Example = "eks-cloudwatch-otlp"
  })
}

#--------------------------------------------------------------
# Amazon Managed Grafana Workspace
#--------------------------------------------------------------

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.1"

  name                      = local.name
  description               = "Grafana workspace for EKS CloudWatch OTLP monitoring"
  associate_license         = false
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS"]
  notification_destinations = ["SNS"]
  grafana_version           = "10.4"

  configuration = jsonencode({
    unifiedAlerting = { enabled = true }
    plugins         = { pluginAdminEnabled = true }
  })

  create_iam_role                = true
  iam_role_name                  = "${local.name}-grafana"
  use_iam_role_name_prefix       = true
  iam_role_force_detach_policies = true

  tags = local.tags
}

#--------------------------------------------------------------
# Grafana Service Account + Token
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

#--------------------------------------------------------------
# EKS Monitoring Module (CloudWatch OTLP profile)
#--------------------------------------------------------------

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana.provisioner
  }

  collector_profile = "cloudwatch-otlp"
  eks_cluster_id    = var.eks_cluster_id

  # CloudWatch OTLP — defaults to regional endpoint if empty
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint
  cloudwatch_log_group        = var.cloudwatch_log_group
  cloudwatch_log_stream       = var.cloudwatch_log_stream

  # AMP not needed
  create_amp_workspace = false

  # Dashboards provisioned via Grafana provider
  enable_dashboards = var.grafana_endpoint != "" ? true : false

  tags = local.tags
}
