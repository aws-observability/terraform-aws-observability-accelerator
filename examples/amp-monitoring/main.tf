provider "aws" {
    region = local.region
}

provider "grafana" {
  url  = module.eks_observability_accelerator.managed_grafana_workspace_endpoint
  auth = var.grafana_api_key
}

locals {
    region = var.aws_region

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
  enable_amazon_eks_adot = false

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = false

  # creates a new AMP workspace, defaults to true
  enable_managed_prometheus = false

  # reusing existing AMP if specified
  managed_prometheus_workspace_id     = var.managed_prometheus_workspace_id
  managed_prometheus_workspace_region = null # defaults to the current region, useful for cross region scenarios (same account)

  # sets up the AMP alert manager at the workspace level
  enable_alertmanager = false

  # reusing existing Amazon Managed Grafana workspace
  enable_managed_grafana       = false
  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  grafana_api_key              = var.grafana_api_key

  tags = local.tags
}

module "amp_monitor" {
    source = "../../modules/workloads/amp-monitoring"
    dashboards_folder_id = module.eks_observability_accelerator.grafana_dashboards_folder_id
    depends_on = [
    module.eks_observability_accelerator
    ]
}

