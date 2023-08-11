data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}

data "aws_iam_policy" "irsa" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

locals {
  name            = "adot-exporter-for-eks-on-ec2"
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]
  # https://github.com/aws-observability/aws-otel-helm-charts/tree/main/charts/adot-exporter-for-eks-on-ec2
  default_helm_config = {
    name        = local.name
    chart       = "adot-exporter-for-eks-on-ec2"
    repository  = "https://aws-observability.github.io/aws-otel-helm-charts"
    version     = var.adot_otel_helm_chart_verison
    namespace   = "amazon-metrics"
    values      = local.default_helm_values
    description = "ADOT Helm Chart Deployment Configuration for Container Insights"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region        = local.addon_context.aws_region_name
    cluster_name      = local.addon_context.eks_cluster_id
    service_receivers = format("[\"%s\"]", var.service_receivers)
    service_exporters = format("[\"%s\"]", var.service_exporters)
    service_account   = local.service_account
  })]

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = concat([data.aws_iam_policy.irsa.arn], var.irsa_policies)
  }

  eks_oidc_issuer_url = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }
}
