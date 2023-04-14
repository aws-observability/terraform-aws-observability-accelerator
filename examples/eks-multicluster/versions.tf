terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.25.0"
    }
  }
}
