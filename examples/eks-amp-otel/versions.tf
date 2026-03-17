terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {}

provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_api_key
}
