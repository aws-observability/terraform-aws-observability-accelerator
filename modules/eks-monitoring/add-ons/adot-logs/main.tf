resource "aws_cloudwatch_log_group" "adot_log_group" {
  count = var.addon_config.enable_logs ? 1 : 0

  name = "/aws/eks/observability-accelerator/${var.addon_context.eks_cluster_id}/workloads"

  retention_in_days = var.addon_config.logs_config.cw_log_retention_days

  tags = var.addon_context.tags
}

resource "aws_iam_policy" "adot_logs_iam_policy" {
  count = var.addon_config.enable_logs ? 1 : 0

  name        = "${substr(var.addon_context.eks_cluster_id, 0, 30)}-${var.addon_context.aws_region_name}-adot-logs-policy"
  path        = "/"
  description = "IAM Policy for ADOT Container Logs Collector"

  policy = data.aws_iam_policy_document.adot_logs_iam_policy.json
  tags   = var.addon_context.tags
}

module "adot_logs_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  count = var.addon_config.enable_logs ? 1 : 0

  role_name = "${substr(var.addon_context.eks_cluster_id, 0, 30)}-${var.addon_context.aws_region_name}-adot-logs-irsa"

  role_policy_arns = {
    policy = resource.aws_iam_policy.adot_logs_iam_policy[0].arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.addon_context.eks_oidc_provider_arn
      namespace_service_accounts = ["opentelemetry-operator-system:adot-col-container-logs"]
    }
  }

  tags = var.addon_context.tags
}
