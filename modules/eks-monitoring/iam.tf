#--------------------------------------------------------------
# IRSA Role for OTel Collector
#--------------------------------------------------------------

module "collector_irsa_role" {
  count   = local.needs_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33"

  role_name = "${var.eks_cluster_id}-otel-collector"

  # AMP remote write policy (self-managed-amp only)
  attach_amazon_managed_service_prometheus_policy = local.is_self_managed_amp

  oidc_providers = {
    ex = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.collector_namespace}:otel-collector"]
    }
  }

  role_policy_arns = merge(
    # CloudWatch metrics for cloudwatch-otlp
    local.is_cloudwatch_otlp ? {
      cw_agent = "arn:${local.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
    } : {},

    # X-Ray write for traces
    var.enable_tracing && (local.is_self_managed_amp || local.is_cloudwatch_otlp) ? {
      xray = "arn:${local.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : {},

    # CloudWatch Logs
    var.enable_logs && (local.is_self_managed_amp || local.is_cloudwatch_otlp) ? {
      cw_logs = "arn:${local.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
    } : {},
  )

  tags = var.tags
}
