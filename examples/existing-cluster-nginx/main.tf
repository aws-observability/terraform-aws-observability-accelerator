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

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.25.0"
    }
  }
}

locals {
  name   = basename(path.cwd)
  region = var.aws_region

  eks_oidc_issuer_url  = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint
  eks_cluster_version  = data.aws_eks_cluster.this.version

  create_new_workspace = var.managed_prometheus_workspace_id == "" ? true : false

  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}

module "eks_observability_accelerator" {
  # source = "aws-observability/terrarom-aws-observability-accelerator"
  source = "../../"

  aws_region     = var.aws_region
  eks_cluster_id = var.eks_cluster_id

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  # creates a new AMP workspace, defaults to true
  enable_managed_prometheus = local.create_new_workspace

  # reusing existing AMP if specified
  managed_prometheus_workspace_id     = var.managed_prometheus_workspace_id
  managed_prometheus_workspace_region = null # defaults to the current region, useful for cross region scenarios (same account)

  # sets up the AMP alert manager at the workspace level
  enable_alertmanager = true

  # reusing existing Amazon Managed Grafana workspace
  enable_managed_grafana       = false
  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  grafana_api_key              = var.grafana_api_key

  tags = local.tags
}

provider "grafana" {
  url  = module.eks_observability_accelerator.managed_grafana_workspace_endpoint
  auth = var.grafana_api_key
}

module "workloads_nginx" {
  source = "../../modules/workloads/nginx"

  eks_cluster_id = module.eks_observability_accelerator.eks_cluster_id

  dashboards_folder_id            = module.eks_observability_accelerator.grafana_dashboards_folder_id
  managed_prometheus_workspace_id = module.eks_observability_accelerator.managed_prometheus_workspace_id

  managed_prometheus_workspace_endpoint = module.eks_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.eks_observability_accelerator.managed_prometheus_workspace_region

  tags = local.tags

  depends_on = [
    module.eks_observability_accelerator
  ]
}