terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "aws-observability-accelerator-terraform-states"
  #   region = "us-west-2"
  #   key    = "e2e/existing-cluster-with-base-and-infra/terraform.tfstate"
  # }

}
