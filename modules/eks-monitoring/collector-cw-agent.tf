#--------------------------------------------------------------
# CloudWatch Agent Helm Release (cloudwatch-otlp profile)
#
# Deploys the Amazon CloudWatch Observability chart which includes:
#   - CloudWatch Agent DaemonSet (metrics + Container Insights)
#   - CloudWatch Agent Operator
#   - Fluent Bit DaemonSet (container logs)
#   - kube-state-metrics
#   - node-exporter
#   - Cluster scraper Deployment (kube-state-metrics + apiserver)
#
# Currently uses a Helm release from a local or custom chart path.
# TODO: Switch to aws_eks_addon once the upstream add-on ships
#       with OTELContainerInsights (Zeus) support.
#--------------------------------------------------------------

resource "helm_release" "cloudwatch_agent" {
  count = local.is_cloudwatch_otlp ? 1 : 0

  name       = "amazon-cloudwatch"
  chart      = var.cw_agent_chart_path
  namespace  = var.cw_agent_namespace
  version    = var.cw_agent_chart_version

  create_namespace = true
  max_history      = 3

  # Helm v3 provider uses set as a list attribute, not blocks.
  set = concat(
    [
      {
        name  = "clusterName"
        value = var.eks_cluster_id
      },
      {
        name  = "region"
        value = local.region
      },
      # Enable OTel-based Container Insights (sends metrics via OTLP to Zeus)
      {
        name  = "OTELContainerInsights.enabled"
        value = "true"
      },
      # Disable legacy Container Insights (mutually exclusive with OTEL CI)
      {
        name  = "containerInsights.enabled"
        value = "false"
      },
      # Container logs via Fluent Bit
      {
        name  = "containerLogs.enabled"
        value = tostring(var.cw_agent_enable_container_logs)
      },
      # Application Signals (auto-instrumentation)
      {
        name  = "manager.applicationSignals.autoMonitor.monitorAllServices"
        value = tostring(var.cw_agent_enable_application_signals)
      },
    ],
    # Override the CloudWatch Metrics OTLP endpoint if provided
    var.cloudwatch_metrics_endpoint != "" ? [
      {
        name  = "OTELContainerInsights.cloudwatchMetricsEndpoint"
        value = var.cloudwatch_metrics_endpoint
      },
    ] : [],
  )
}
