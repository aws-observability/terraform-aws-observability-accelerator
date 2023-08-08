data "aws_iam_policy_document" "irsa" {
    statement {
        sid = "CreateCWLogs"
        effect = "Allow"
        resources = ["*"]
        actions = [
            "cloudwatch:PutMetricData",
            "ec2:DescribeVolumes",
            "ec2:DescribeTags",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups",
            "logs:CreateLogStream",
            "logs:CreateLogGroup"
        ]
    }
    statement {
        sid = "SSMParameter"
        effect = "Allow"
        resources = ["arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"]
        actions = ["ssm:GetParameter"]
    }
}