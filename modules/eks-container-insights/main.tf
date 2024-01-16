locals {
  name = "amazon-cloudwatch-observability"
}

module "cloudwatch_observability_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  count  = var.create_cloudwatch_observability_irsa_role ? 1 : 0

  role_name                              = "cloudwatch-observability"
  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

data "aws_eks_addon_version" "eks_addon_version" {
  addon_name         = local.name
  kubernetes_version = var.kubernetes_version
  most_recent        = var.most_recent
}

resource "aws_eks_addon" "amazon-cloudwatch-observability" {
  count = var.enable_amazon_eks_cw_observability ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = local.name
  addon_version               = try(var.addon_config.addon_version, data.aws_eks_addon_version.eks_addon_version.version)
  resolve_conflicts_on_create = try(var.addon_config.resolve_conflicts_on_create, "OVERWRITE")
  service_account_role_arn    = try(module.cloudwatch_observability_irsa_role[0].iam_role_arn, null)
  preserve                    = try(var.addon_config.preserve, true)
  configuration_values        = try(var.addon_config.configuration_values, null)

  tags = merge(
    # var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

resource "aws_iam_service_linked_role" "application-signals-cw" {
  count            = var.create_cloudwatch_application_signals_role ? 1 : 0
  aws_service_name = "application-signals.cloudwatch.amazonaws.com"
}
