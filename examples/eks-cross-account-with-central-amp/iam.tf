data "aws_caller_identity" "monitoring" {
  provider = aws.central_monitoring
}

resource "aws_iam_policy" "irsa_assume_role_policy_one" {
  provider    = aws.eks_cluster_one
  name        = "${var.cluster_one.name}-irsa_assume_role_policy"
  path        = "/"
  description = "This role allows the IRSA role to assume the cross-account role for AMP access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.monitoring.account_id}:role/${local.amp_workspace_alias}-role-for-cross-account"
      },
    ]
  })
}

resource "aws_iam_policy" "irsa_assume_role_policy_two" {
  provider    = aws.eks_cluster_two
  name        = "${var.cluster_two.name}-irsa_assume_role_policy"
  path        = "/"
  description = "This role allows the IRSA role to assume the cross-account role for AMP access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.monitoring.account_id}:role/${local.amp_workspace_alias}-role-for-cross-account"
      },
    ]
  })
}

resource "aws_iam_role" "cross_account_amp_role" {
  provider = aws.central_monitoring
  name     = "${local.amp_workspace_alias}-role-for-cross-account"

  assume_role_policy = <<EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": [
                            "${module.eks_monitoring_one.adot_irsa_arn}",
                            "${module.eks_monitoring_two.adot_irsa_arn}"
                        ]
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {}
                }
            ]
        }
    EOF
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  provider   = aws.central_monitoring
  role       = aws_iam_role.cross_account_amp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}
