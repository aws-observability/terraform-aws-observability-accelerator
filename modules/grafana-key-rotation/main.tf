data "archive_file" "lambda_function_archive" {
  type = "zip"

  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}


data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Unique random string to avoid Resource Already Exists errors.
resource "random_string" "random_string_resource" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

# Lambda function resource
resource "aws_lambda_function" "observability_accelerator_lambda" {
  function_name = "${var.lambda_function_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime_grafana_key_rotation
  memory_size   = 128
  timeout       = 180
  filename      = data.archive_file.lambda_function_archive.output_path
  role          = aws_iam_role.lambda_role.arn
}


# Lambda Execution IAM Role
resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_execution_role_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}


# Policy Attachment to associate the custom policy created below to Lambda Execution Role
resource "aws_iam_policy_attachment" "lambda_execution_role_policy_attach" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_execution_role_policy.arn
}

# Policy for Lambda Execution Role with ssm,kms,logs,grafana permissions
resource "aws_iam_policy" "lambda_execution_role_policy" {
  name        = "${var.lambda_execution_role_policy_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  path        = "/"
  description = "Policy for Lambda function with SSM and Grafana related permissions"
  policy      = data.aws_iam_policy_document.lambda_execution_role_policy_document.json
}

# Policy _document_ for Lambda Execution Role
data "aws_iam_policy_document" "lambda_execution_role_policy_document" {
  statement {
    sid = "ssm"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [var.ssmparameter_arn]
    effect    = "Allow"
  }
  statement {
    sid       = "kms"
    actions   = ["kms:Encrypt"]
    effect    = "Allow"
    resources = [var.kms_key_arn_ssm]
  }
  statement {
    sid = "grafana"
    actions = [
      "grafana:CreateWorkspaceApiKey",
      "grafana:DeleteWorkspaceApiKey"
    ]
    resources = ["arn:aws:grafana:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/workspaces/${var.managed_grafana_workspace_id}"]
    effect    = "Allow"
  }
  statement {
    sid = "logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}


# EventBridge Scheduler - Rate based
resource "aws_scheduler_schedule" "eventbridge_scheduler" {
  name = "${var.eventbridge_scheduler_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.eventbridge_scheduler_schedule_expression
  target {
    arn      = aws_lambda_function.observability_accelerator_lambda.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
    input = jsonencode({
      ssmparameter = var.ssmparameter_name
      interval     = var.grafana_api_key_interval
      workspaceid  = var.managed_grafana_workspace_id
    })
  }
}

# EventBridge Scheduler Execution IAM Role
resource "aws_iam_role" "eventbridge_scheduler_role" {
  name               = "${var.eventbridge_scheduler_role_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "scheduler.amazonaws.com"
    },
     "Condition": {
        "StringEquals": {
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
    },
    "Effect": "Allow",
    "Sid": "1"
    }
]
}
EOF
}

# Policy Attachment to associate the custom policy created below to EventBridge Execution Role
resource "aws_iam_policy_attachment" "eventbridge_scheduler_role_policy_attach" {
  name       = "eventbridge-policy-attachment"
  roles      = [aws_iam_role.eventbridge_scheduler_role.name]
  policy_arn = aws_iam_policy.eventbridge_scheduler_role_policy.arn
}

# Policy for EventBridge Execution Role with Lambda invoke permissions
resource "aws_iam_policy" "eventbridge_scheduler_role_policy" {
  name        = "${var.eventbridge_scheduler_role_policy_name}-${var.managed_grafana_workspace_id}-${random_string.random_string_resource.id}"
  path        = "/"
  description = "Policy for EventBridge Scheduler to invoke observability accelerator Lambda Function"
  policy      = data.aws_iam_policy_document.eventbridge_scheduler_role_policy_document.json
}

# Policy _document_ for EventBridge Execution Role with Lambda invoke permissions
data "aws_iam_policy_document" "eventbridge_scheduler_role_policy_document" {
  statement {
    sid     = "1"
    actions = ["lambda:InvokeFunction"]
    resources = [
      "${aws_lambda_function.observability_accelerator_lambda.arn}",
      "${aws_lambda_function.observability_accelerator_lambda.arn}:*"
    ]
    effect = "Allow"
  }
}
