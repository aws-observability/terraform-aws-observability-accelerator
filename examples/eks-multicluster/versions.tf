terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.55.0"
      configuration_aliases = [aws.eks_cluster_1, aws.eks_cluster_2]
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.18.0"
      configuration_aliases = [kubernetes.eks_cluster_1, kubernetes.eks_cluster_2]
    }
    helm = {
      source                = "hashicorp/helm"
      version               = ">= 2.9.0"
      configuration_aliases = [helm.eks_cluster_1, helm.eks_cluster_2]
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.3"
    }
  }
}
