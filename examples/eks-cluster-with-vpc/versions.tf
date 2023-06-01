terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.40.1"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "aws-observability-accelerator-terraform-states"
  #   region = "us-west-2"
  #   key    = "e2e/eks-cluster-with-vpc/terraform.tfstate"
  # }
}
