provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
      command     = "aws"
    }
  }
}


# Deploy the CW Application Signals and Container Insights

module "eks_container_insights" {
  source         = "../../modules/eks-container-insights"
  eks_cluster_id = var.eks_cluster_id
}
