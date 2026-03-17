#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

#--------------------------------------------------------------
# Profile Routing Booleans
#--------------------------------------------------------------

locals {
  # Profile selection booleans
  is_managed_metrics  = var.collector_profile == "managed-metrics"
  is_self_managed_amp = var.collector_profile == "self-managed-amp"
  is_cloudwatch_otlp  = var.collector_profile == "cloudwatch-otlp"

  # Derived booleans
  needs_otel_helm = local.is_self_managed_amp || local.is_cloudwatch_otlp
  needs_irsa      = local.needs_otel_helm
  is_amp_flavor   = local.is_managed_metrics || local.is_self_managed_amp
  is_cw_flavor    = local.is_cloudwatch_otlp
}

#--------------------------------------------------------------
# Common Computed Values
#--------------------------------------------------------------

locals {
  region               = data.aws_region.current.id
  partition            = data.aws_partition.current.partition
  account_id           = data.aws_caller_identity.current.account_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
}

#--------------------------------------------------------------
# AMP Workspace Computation
#--------------------------------------------------------------

locals {
  amp_workspace_id = var.create_amp_workspace ? aws_prometheus_workspace.this[0].id : var.managed_prometheus_workspace_id

  amp_workspace_arn = var.create_amp_workspace ? aws_prometheus_workspace.this[0].arn : (
    var.managed_prometheus_workspace_id != null ? data.aws_prometheus_workspace.existing[0].arn : null
  )

  amp_workspace_endpoint = local.is_amp_flavor ? "https://aps-workspaces.${local.region}.amazonaws.com/workspaces/${local.amp_workspace_id}/" : null
}

# Precondition: fail when create_amp_workspace = false and no workspace ID provided
resource "terraform_data" "amp_workspace_validation" {
  count = local.is_amp_flavor && !var.create_amp_workspace ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.managed_prometheus_workspace_id != null
      error_message = "managed_prometheus_workspace_id must be provided when create_amp_workspace is false and an AMP flavor profile is selected"
    }
  }
}
