terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0"
      configuration_aliases = [aws.eks_cluster_1, aws.eks_cluster_2]
    }
    helm = {
      source                = "hashicorp/helm"
      version               = ">= 3.0.0"
      configuration_aliases = [helm.eks_cluster_1, helm.eks_cluster_2]
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.0.0"
    }
  }
}
