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

locals {
  region               = var.aws_region
  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint
  create_new_workspace = var.managed_prometheus_workspace_id == "" ? true : false

  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}

module "aws_observability_accelerator" {
  source = "../../"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator?ref=v2.0.0"

  aws_region = var.aws_region

  # creates a new AMP workspace, defaults to true
  enable_managed_prometheus = local.create_new_workspace

  # reusing existing AMP if specified
  managed_prometheus_workspace_id = var.managed_prometheus_workspace_id

  # reusing existing Amazon Managed Grafana workspace
  managed_grafana_workspace_id = var.managed_grafana_workspace_id

  tags = local.tags
}

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"

  # enable NGINX metrics collection, dashboards and alerts rules creation
  enable_nginx = true

  eks_cluster_id = var.eks_cluster_id

  # deploys external-secrets in to the cluster
  enable_external_secrets = true
  grafana_api_key         = var.grafana_api_key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  # control the publishing of dashboards by specifying the boolean value for the variable 'enable_dashboards', default is 'true'
  enable_dashboards = var.enable_dashboards

  managed_prometheus_workspace_id = module.aws_observability_accelerator.managed_prometheus_workspace_id

  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region

  enable_logs = true

  tags = local.tags

  depends_on = [
    module.aws_observability_accelerator
  ]
}
