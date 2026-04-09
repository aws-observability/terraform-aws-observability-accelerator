#--------------------------------------------------------------
# IRSA Role for OTel Collector (self-managed-amp only)
#--------------------------------------------------------------

module "collector_irsa_role" {
  count   = local.needs_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33"

  role_name = "${var.eks_cluster_id}-otel-collector"

  attach_amazon_managed_service_prometheus_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.collector_namespace}:otel-collector"]
    }
  }

  role_policy_arns = merge(
    var.enable_tracing ? {
      xray = "arn:${local.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : {},
    var.enable_logs ? {
      cw_logs = "arn:${local.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
    } : {},
  )

  tags = var.tags
}
