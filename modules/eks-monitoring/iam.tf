#--------------------------------------------------------------
# IRSA Role for OTel Collector (self-managed-amp only)
#--------------------------------------------------------------

module "collector_irsa_role" {
  count   = local.needs_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33"

  role_name = "${var.eks_cluster_id}-otel-collector"

  # AMP: attach managed Prometheus remote write policy
  attach_amazon_managed_service_prometheus_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.collector_namespace}:otel-collector"]
    }
  }

  role_policy_arns = merge(
    # X-Ray write for traces
    var.enable_tracing ? {
      xray = "arn:${local.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : {},

    # CloudWatch Logs for logs pipeline
    var.enable_logs ? {
      cw_logs = "arn:${local.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
    } : {},
  )

  tags = var.tags
}

#--------------------------------------------------------------
# IAM Role for CloudWatch Agent (cloudwatch-otlp profile)
#
# The CW Agent needs CloudWatchAgentServerPolicy attached to
# the EKS node IAM role. This module outputs the policy ARN
# so the caller can attach it to their node group role.
#
# When the upstream EKS add-on supports Zeus, this will switch
# to Pod Identity associations instead.
#--------------------------------------------------------------

# No IRSA needed — the CW Agent chart's SA template doesn't
# support annotations. IAM permissions come from the node role.
# The example and AGENT.md document attaching the managed policy.
# TODO(launch): Switch to Pod Identity when aws_eks_addon supports Zeus.
# This will also enable EKS Auto Mode support.
