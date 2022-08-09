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

# deploys the base module
module "eks_observability_accelerator" {
  # source = "aws-ia/terrarom-aws-observability-accelerator?ref=dev"
  source = "../../"

  aws_region     = var.aws_region
  eks_cluster_id = var.eks_cluster_id

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  # # -- or enable opentelemetry operator
  enable_opentelemetry_operator = false
  #open_telemetry_operator_config = map() // custom config

  # creates a new AMP workspace, defaults to true
  enable_managed_prometheus = false

  # reusing existing AMP -- needs data source for alerting rules
  managed_prometheus_id     = var.managed_prometheus_workspace_id
  managed_prometheus_region = null # defaults to the current region, useful for cross region scenarios (same account)

  # sets up the AMP alert manager at the workspace level
  enable_alertmanager = true

  # create a new Grafana workspace - TODO review design
  enable_managed_grafana       = false
  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  grafana_api_key              = var.grafana_api_key

  tags = local.tags
}

module "workloads_infra" {
  source = "../../workloads/infra"
  # source = "aws-ia/terrarom-aws-observability-accelerator/workloads/infra?ref=dev"


  enable_infra_metrics = true
  # infra_metrics_config = {}
}
