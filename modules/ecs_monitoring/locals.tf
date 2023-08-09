data "aws_region" "current" {}

locals {
  taskRoleArn      = var.taskRoleArn
  executionRoleArn = var.executionRoleArn
  region           = data.aws_region.current.name
  name             = "amg-ex-${replace(basename(path.cwd), "_", "-")}"
  description      = "AWS Managed Grafana service for ${local.name}"
}
