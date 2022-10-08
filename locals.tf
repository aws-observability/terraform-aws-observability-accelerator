data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}

data "aws_grafana_workspace" "this" {
  count        = var.managed_grafana_workspace_id == "" ? 0 : 1
  workspace_id = var.managed_grafana_workspace_id
}

locals {
  eks_oidc_issuer_url  = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = data.aws_eks_cluster.eks_cluster.endpoint
  eks_cluster_version  = data.aws_eks_cluster.eks_cluster.version

  # if region is not passed, we assume the current one
  amp_ws_region   = coalesce(var.managed_prometheus_workspace_region, data.aws_region.current.name)
  amp_ws_id       = var.enable_managed_prometheus ? aws_prometheus_workspace.this[0].id : var.managed_prometheus_workspace_id
  amp_ws_endpoint = "https://aps-workspaces.${local.amp_ws_region}.amazonaws.com/workspaces/${local.amp_ws_id}/"

  # if grafana_workspace_id is supplied, we infer the endpoint from
  # computed region, else we create a new workspace
  amg_ws_endpoint = var.managed_grafana_workspace_id == "" ? "https://${module.managed_grafana[0].workspace_endpoint}" : "https://${data.aws_grafana_workspace.this[0].endpoint}"
  amg_ws_id       = var.managed_grafana_workspace_id == "" ? split(".", module.managed_grafana[0].workspace_endpoint)[0] : var.managed_grafana_workspace_id

  context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = local.eks_cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }

  name = "aws-observability-accelerator"
}
