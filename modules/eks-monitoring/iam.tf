#--------------------------------------------------------------
# IRSA Role for OTel Collector (self-managed-amp, cloudwatch-otlp)
#--------------------------------------------------------------

module "collector_irsa_role" {
  count   = local.needs_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33"

  role_name = "${var.eks_cluster_id}-otel-collector"

  # AMP flavor: attach managed Prometheus remote write policy
  attach_amazon_managed_service_prometheus_policy = local.is_self_managed_amp

  oidc_providers = {
    ex = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.collector_namespace}:otel-collector"]
    }
  }

  role_policy_arns = merge(
    # Self-managed AMP: X-Ray write for traces
    local.is_self_managed_amp && var.enable_tracing ? {
      xray = "arn:${local.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : {},

    # Self-managed AMP: CloudWatch Logs for logs pipeline
    local.is_self_managed_amp && var.enable_logs ? {
      cw_logs = "arn:${local.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
    } : {},

    # CloudWatch OTLP: custom PutMetricData policy for metrics via Zeus endpoint
    local.is_cloudwatch_otlp ? {
      cw_put_metric = aws_iam_policy.cloudwatch_put_metric[0].arn
    } : {},

    # CloudWatch OTLP: CloudWatch Logs full access for logs pipeline
    local.is_cloudwatch_otlp ? {
      cw_logs = "arn:${local.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
    } : {},

    # CloudWatch OTLP: X-Ray write for traces pipeline
    local.is_cloudwatch_otlp ? {
      xray = "arn:${local.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
    } : {},
  )

  tags = var.tags
}

#--------------------------------------------------------------
# Custom IAM Policy: cloudwatch:PutMetricData (cloudwatch-otlp)
#--------------------------------------------------------------

resource "aws_iam_policy" "cloudwatch_put_metric" {
  count       = local.is_cloudwatch_otlp ? 1 : 0
  name_prefix = "${var.eks_cluster_id}-cw-put-metric"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["cloudwatch:PutMetricData"]
      Resource = "*"
    }]
  })

  tags = var.tags
}
