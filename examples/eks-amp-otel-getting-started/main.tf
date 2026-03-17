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
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "grafana" {
  url  = "https://${data.aws_grafana_workspace.this.endpoint}"
  auth = var.grafana_api_key
}

data "aws_grafana_workspace" "this" {
  workspace_id = var.managed_grafana_workspace_id
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
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  # Creates a new AMP workspace; set to false and provide
  # managed_prometheus_workspace_id to reuse an existing one
  create_amp_workspace            = var.managed_prometheus_workspace_id == "" ? true : false
  managed_prometheus_workspace_id = var.managed_prometheus_workspace_id != "" ? var.managed_prometheus_workspace_id : null

  # Enable all pipelines
  enable_tracing = true
  enable_logs    = true

  # Dashboards provisioned via Grafana Terraform provider
  enable_dashboards = var.enable_dashboards

  # AMP recording and alerting rules
  enable_recording_rules = true
  enable_alerting_rules  = true

  # Optional: scrape interval tuning
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  tags = local.tags
}
