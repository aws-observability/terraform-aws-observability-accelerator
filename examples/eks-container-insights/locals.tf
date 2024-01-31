locals {
  name                = "amazon-cloudwatch-observability"
  eks_oidc_issuer_url = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    eks_cluster_id                 = data.aws_eks_cluster.eks_cluster.id
    tags                           = var.tags
  }

  addon_config = {
    kubernetes_version = var.eks_cluster_version
    most_recent        = true
  }
}
