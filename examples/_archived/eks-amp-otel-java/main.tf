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

  # Java/JMX scrape target — update the target to match your application
  additional_scrape_jobs = [
    {
      job_name        = "java-jmx"
      scrape_interval = "30s"
      scrape_timeout  = "15s"
      static_configs = [
        { targets = ["tomcat-example.javajmx-sample.svc.cluster.local:9404"] }
      ]
    }
  ]

  # Java/JMX dashboard
  dashboard_sources = {
    java-jmx = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/java/default.json"
  }

  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  tags = local.tags
}
