provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

data "aws_grafana_workspace" "this" {
  workspace_id = var.managed_grafana_workspace_id
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "grafana" {
  url  = "https://${data.aws_grafana_workspace.this.endpoint}"
  auth = var.grafana_api_key
}

locals {
  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile     = "self-managed-amp"
  eks_cluster_id        = var.eks_cluster_id

  create_amp_workspace            = var.managed_prometheus_workspace_id == "" ? true : false
  managed_prometheus_workspace_id = var.managed_prometheus_workspace_id != "" ? var.managed_prometheus_workspace_id : null

  enable_dashboards = var.enable_dashboards
  enable_tracing    = true
  enable_logs       = true

  # NGINX scrape target — update the target to match your NGINX ingress controller
  additional_scrape_jobs = [
    {
      job_name        = "nginx"
      scrape_interval = "30s"
      static_configs = [
        { targets = ["my-nginx-ingress-nginx-controller-metrics.nginx-ingress-sample.svc.cluster.local:10254"] }
      ]
    }
  ]

  # NGINX dashboard
  dashboard_sources = {
    nginx = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/nginx/nginx.json"
  }

  tags = local.tags
}
