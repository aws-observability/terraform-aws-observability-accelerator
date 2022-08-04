

module "eks_observability_accelerator" {
  #source = "aws-ia/terrarom-aws-observability-accelerator"
  source = "../"

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

  # enable workload-specific collector, metrics, alerts and dashboards
  enable_java                 = false
  enable_java_recording_rules = false

  # enable_haproxy = true
  # haproxy_config = {
  #   amp_endpoint     = module / amp.endpoint
  #   grafana_endpoint = module.grafana.endpoint
  # }

  enable_infra_metrics = true
  #infra_metrics_config = {}

  tags = local.tags
}
# module "amp" {

# }

# module "grafana" {

# }
