###### AWS Providers ######

provider "aws" {
  region = var.cluster_one.region
  alias  = "eks_cluster_one"
  assume_role {
    role_arn = var.cluster_one.tf_role
  }
}

provider "aws" {
  region = var.cluster_two.region
  alias  = "eks_cluster_two"
  assume_role {
    role_arn = var.cluster_two.tf_role
  }
}

provider "aws" {
  region = var.monitoring.region
  alias  = "central_monitoring"
  assume_role {
    role_arn = var.monitoring.tf_role
  }
}

###### Helm Providers ######

provider "helm" {
  alias = "eks_cluster_one"
  kubernetes {
    host                   = data.aws_eks_cluster.eks_one.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_one.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--role-arn", var.cluster_one.tf_role, "--cluster-name", var.cluster_one.name]
      command     = "aws"
    }
  }
}

provider "helm" {
  alias = "eks_cluster_two"
  kubernetes {
    host                   = data.aws_eks_cluster.eks_two.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_two.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--role-arn", var.cluster_two.tf_role, "--cluster-name", var.cluster_two.name]
      command     = "aws"
    }
  }
}

###### Kubernetes Providers ######

provider "kubernetes" {
  alias                  = "eks_cluster_one"
  host                   = data.aws_eks_cluster.eks_one.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_one.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--role-arn", var.cluster_one.tf_role, "--cluster-name", var.cluster_one.name]
    command     = "aws"
  }
}

provider "kubernetes" {
  alias                  = "eks_cluster_two"
  host                   = data.aws_eks_cluster.eks_two.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_two.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--role-arn", var.cluster_two.tf_role, "--cluster-name", var.cluster_two.name]
    command     = "aws"
  }
}

provider "kubectl" {
  alias                  = "eks_cluster_one"
  apply_retry_count      = 30
  host                   = data.aws_eks_cluster.eks_one.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_one.certificate_authority[0].data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.eks_one.token
}

provider "kubectl" {
  alias                  = "eks_cluster_two"
  apply_retry_count      = 30
  host                   = data.aws_eks_cluster.eks_two.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_two.certificate_authority[0].data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.eks_two.token
}
