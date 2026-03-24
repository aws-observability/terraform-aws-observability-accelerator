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
# Attach CloudWatchAgentServerPolicy to EKS node role
#
# The CW Agent DaemonSet runs on every node and needs IAM
# permissions to send metrics/logs/traces to CloudWatch.
# Until the upstream EKS add-on supports Pod Identity for
# Zeus, the simplest path is node-level IAM.
#--------------------------------------------------------------

data "aws_eks_node_groups" "this" {
  cluster_name = var.eks_cluster_id
}

data "aws_eks_node_group" "first" {
  cluster_name    = var.eks_cluster_id
  node_group_name = tolist(data.aws_eks_node_groups.this.names)[0]
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = regex(".*/(.*)", data.aws_eks_node_group.first.node_role_arn)[0]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
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

  # CW Agent chart — use local path for pre-release testing
  cw_agent_chart_path = var.cw_agent_chart_path

  # CloudWatch OTLP — defaults to regional endpoint if empty
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint

  # AMP not needed
  create_amp_workspace = false

  # Dashboards provisioned via Grafana provider
  enable_dashboards = var.grafana_endpoint != "" ? true : false

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.cw_agent]
}
