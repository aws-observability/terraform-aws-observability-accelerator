data "aws_iam_policy_document" "adot_logs_iam_policy" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:/aws/eks/observability-accelerator/${var.addon_context.eks_cluster_id}/workloads:log-stream:*"]
    actions   = ["logs:PutLogEvents"]
  }

  statement {
    sid       = "DescribeLogGroups"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:DescribeLogGroups",
    ]
  }

  statement {
    sid    = "LogStreams"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:/aws/eks/observability-accelerator/${var.addon_context.eks_cluster_id}/workloads",
      "arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:/aws/eks/observability-accelerator/${var.addon_context.eks_cluster_id}/workloads:log-stream:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
    ]
  }

}
