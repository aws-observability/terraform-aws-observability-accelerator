data "aws_iam_policy_document" "irsa" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:*:log-stream:*"]
    actions   = ["logs:PutLogEvents"]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
    ]
  }

}
