provider "aws" {
  region = local.region
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# provider "grafana" {
#   url  = var.grafana_endpoint
#   auth = var.grafana_api_key
# }

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.24.0"
    }
  }
}

locals {
  name   = basename(path.cwd)
  region = var.aws_region

  eks_oidc_issuer_url  = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint
  eks_cluster_version  = data.aws_eks_cluster.this.version

  tags = {
    Source = "github.com/aws-ia/terraform-aws-observability-accelerator"
  }
}
