###### AWS Providers ######

provider "aws" {
  region  = var.cluster_one.region
  alias   = "eks_cluster_one"
  assume_role {
    role_arn = var.cluster_one.tf_role
  }
}

provider "aws" {
  region  = var.cluster_two.region
  alias   = "eks_cluster_two"
  assume_role {
    role_arn = var.cluster_two.tf_role
  }
}

provider "aws" {
  region  = var.monitoring.region
  alias   = "central_monitoring"
  assume_role {
    role_arn = var.monitoring.tf_role
  }
}

###### Helm Providers ######

provider "helm" {
  alias  = "eks_cluster_one"
  kubernetes {
    host                   = module.eks-one.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-one.cluster_certificate_authority_data)
    exec {
      api_version          = "client.authentication.k8s.io/v1beta1"
      args                 = ["eks", "get-token", "--role-arn", var.cluster_one.tf_role, "--cluster-name", module.eks-one.cluster_name]
      command              = "aws"
    }
  }
}

provider "helm" {
  alias  = "eks_cluster_two"
  kubernetes {
    host                   = module.eks-two.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-two.cluster_certificate_authority_data)
    exec {
      api_version          = "client.authentication.k8s.io/v1beta1"
      args                 = ["eks", "get-token", "--role-arn", var.cluster_two.tf_role, "--cluster-name", module.eks-two.cluster_name]
      command              = "aws"
    }
  }
}

###### Kubernetes Providers ######

provider "kubernetes" {
  alias                    = "eks_cluster_one"
  host                     = module.eks-one.cluster_endpoint
  cluster_ca_certificate   = base64decode(module.eks-one.cluster_certificate_authority_data)
  exec {
    api_version            = "client.authentication.k8s.io/v1beta1"
    args                   = ["eks", "get-token", "--role-arn", var.cluster_one.tf_role, "--cluster-name", module.eks-one.cluster_name]
    command                = "aws"
  }
}

provider "kubernetes" {
  alias                    = "eks_cluster_two"
  host                     = module.eks-two.cluster_endpoint
  cluster_ca_certificate   = base64decode(module.eks-two.cluster_certificate_authority_data)
  exec {
    api_version            = "client.authentication.k8s.io/v1beta1"
    args                   = ["eks", "get-token", "--role-arn", var.cluster_two.tf_role, "--cluster-name", module.eks-two.cluster_name]
    command                = "aws"
  }
}

provider "kubectl" {
  alias                    = "eks_cluster_one"
  apply_retry_count        = 30
  host                     = module.eks-one.cluster_endpoint
  cluster_ca_certificate   = base64decode(module.eks-one.cluster_certificate_authority_data)
  load_config_file         = false
  token                    = data.aws_eks_cluster_auth.eks-one.token
}

provider "kubectl" {
  alias                    = "eks_cluster_two"
  apply_retry_count        = 30
  host                     = module.eks-two.cluster_endpoint
  cluster_ca_certificate   = base64decode(module.eks-two.cluster_certificate_authority_data)
  load_config_file         = false
  token                    = data.aws_eks_cluster_auth.eks-two.token
}

data "aws_eks_cluster_auth" "eks-one" {
  provider = aws.eks_cluster_one
  name = module.eks-one.cluster_name
}

data "aws_eks_cluster_auth" "eks-two" {
  provider = aws.eks_cluster_two
  name = module.eks-two.cluster_name
}