terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.55.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.18.0"
      configuration_aliases = [kubernetes.primary, kubernetes.secondary]
    }
    helm = {
      source                = "hashicorp/helm"
      version               = ">= 2.9.0"
      configuration_aliases = [helm.primary, helm.secondary]
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.25.0"
    }
  }
}
