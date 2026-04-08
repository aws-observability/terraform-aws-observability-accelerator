locals {
  tags = {
    Example = "eks-cloudwatch-otlp"
  }
}

#--------------------------------------------------------------
# EKS Monitoring Module (CloudWatch OTLP profile)
#--------------------------------------------------------------

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"

  providers = {
    grafana = grafana
  }

  collector_profile      = "cloudwatch-otlp"
  eks_cluster_id         = var.eks_cluster_id
  cw_agent_addon_version = "v6.0.0-eksbuild.1"

  # OTLP gateway — deploys CWA as a Deployment accepting app telemetry
  enable_otlp_gateway = true

  # CloudWatch OTLP — defaults to regional endpoint if empty
  cloudwatch_metrics_endpoint = var.cloudwatch_metrics_endpoint

  # AMP not needed
  create_amp_workspace = false

  # Dashboards
  enable_dashboards  = var.grafana_endpoint != "" ? true : false
  grafana_endpoint   = var.grafana_endpoint
  grafana_api_key    = var.grafana_api_key

  dashboard_sources = {
    cluster             = "${path.module}/../../dashboards/cloudwatch-otlp/cluster.json"
    containers          = "${path.module}/../../dashboards/cloudwatch-otlp/containers.json"
    gpu-fleet           = "${path.module}/../../dashboards/cloudwatch-otlp/gpu-fleet.json"
    kubelet             = "${path.module}/../../dashboards/cloudwatch-otlp/kubelet.json"
    namespace-workloads = "${path.module}/../../dashboards/cloudwatch-otlp/namespace-workloads.json"
    node-exporter       = "${path.module}/../../dashboards/cloudwatch-otlp/nodeexporter-nodes.json"
    nodes               = "${path.module}/../../dashboards/cloudwatch-otlp/nodes.json"
    unified-service     = "${path.module}/../../dashboards/cloudwatch-otlp/unified-service.json"
    workloads           = "${path.module}/../../dashboards/cloudwatch-otlp/workloads.json"
  }

  tags = local.tags
}
