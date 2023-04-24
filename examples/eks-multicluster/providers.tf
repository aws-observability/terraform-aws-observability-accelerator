provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster_1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_1.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_1.token
  alias                  = "eks_cluster_1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster_2.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_2.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_2.token
  alias                  = "eks_cluster_2"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster_1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_1.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_1.token
  }
  alias = "eks_cluster_1"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster_2.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster_2.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_2.token
  }
  alias = "eks_cluster_2"
}

provider "aws" {
  region = var.eks_cluster_1_region
  alias  = "eks_cluster_1"
}

provider "aws" {
  region = var.eks_cluster_2_region
  alias  = "eks_cluster_2"
}

provider "grafana" {
  url  = module.aws_observability_accelerator.managed_grafana_workspace_endpoint
  auth = var.grafana_api_key
}
