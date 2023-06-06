provider "aws" {
  region = "us-east-1"
  alias  = "billing_region"
}

locals {
  name     = "aws-observability-accelerator-cloudwatch"
  amp_list = toset(split(",", var.managed_prometheus_workspace_ids))
}

module "billing" {
  source = "./billing"
  providers = {
    aws = aws.billing_region
  }
}
