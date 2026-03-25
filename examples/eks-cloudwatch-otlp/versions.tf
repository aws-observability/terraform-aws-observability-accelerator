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

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# Phase 1: grafana_endpoint is empty → use a placeholder URL so the
#           provider initializes without error. Dashboards are skipped
#           because enable_dashboards = false when endpoint is empty.
# Phase 2: re-apply with grafana_endpoint from output → dashboards provisioned.
# The install.sh script automates both phases.
provider "grafana" {
  alias = "provisioner"
  url   = var.grafana_endpoint != "" ? var.grafana_endpoint : "https://placeholder.grafana.local"
  auth  = var.grafana_api_key
}
