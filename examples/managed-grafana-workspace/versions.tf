terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "aws-observability-accelerator-terraform-states"
  #   region = "us-west-2"
  #   key    = "e2e/managed-grafana-workspace/terraform.tfstate"
  # }
}
