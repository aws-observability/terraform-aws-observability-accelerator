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
# When cw_agent_chart_path is set (local path), repository is omitted.
# Otherwise, the chart is pulled from cw_agent_chart_repo.
#
# TODO(launch): Switch to aws_eks_addon once the upstream add-on ships
#       with OTELContainerInsights (Zeus) support. At that point:
#       - Remove cw_agent_chart_path, cw_agent_chart_repo, cw_agent_image vars
#       - Replace helm_release with aws_eks_addon resource
#       - Switch IAM from node role to Pod Identity association
#       - This also enables EKS Auto Mode support
#--------------------------------------------------------------

locals {
  cw_agent_use_local_chart = var.cw_agent_chart_path != ""

  # Parse image override: "registry/repo:tag" → domain, repo, tag
  cw_agent_has_image_override = var.cw_agent_image != ""
  # Split on last colon that follows a non-colon (to handle registry ports)
  # e.g. "123.dkr.ecr.us-east-1.amazonaws.com/cw-agent-dev:latest"
  #   → image_ref = "123.dkr.ecr.us-east-1.amazonaws.com/cw-agent-dev"
  #   → tag = "latest"
  cw_agent_image_parts = local.cw_agent_has_image_override ? regex("^(.+?)(?::([^/]+))?$", var.cw_agent_image) : ["", ""]
  cw_agent_image_ref   = local.cw_agent_image_parts[0]
  cw_agent_image_tag   = local.cw_agent_image_parts[1] != null ? local.cw_agent_image_parts[1] : ""

  # Split image_ref into domain and repository at the first "/"
  # e.g. "123.dkr.ecr.us-east-1.amazonaws.com/cw-agent-dev"
  #   → domain = "123.dkr.ecr.us-east-1.amazonaws.com"
  #   → repo   = "cw-agent-dev"
  cw_agent_image_domain = local.cw_agent_has_image_override ? regex("^([^/]+)/(.+)$", local.cw_agent_image_ref)[0] : ""
  cw_agent_image_repo   = local.cw_agent_has_image_override ? regex("^([^/]+)/(.+)$", local.cw_agent_image_ref)[1] : ""
}

resource "helm_release" "cloudwatch_agent" {
  count = local.is_container_insights ? 1 : 0

  name       = "amazon-cloudwatch"
  repository = local.cw_agent_use_local_chart ? null : var.cw_agent_chart_repo
  chart      = local.cw_agent_use_local_chart ? var.cw_agent_chart_path : "amazon-cloudwatch-observability"
  namespace  = var.cw_agent_namespace
  version    = var.cw_agent_chart_version

  create_namespace = true
  max_history      = 3

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
      {
        name  = "OTELContainerInsights.enabled"
        value = "true"
      },
      {
        name  = "containerInsights.enabled"
        value = "false"
      },
      {
        name  = "containerLogs.enabled"
        value = tostring(var.cw_agent_enable_container_logs)
      },
      {
        name  = "manager.applicationSignals.autoMonitor.monitorAllServices"
        value = tostring(var.cw_agent_enable_application_signals)
      },
    ],
    # Override CloudWatch Metrics OTLP endpoint
    var.cloudwatch_metrics_endpoint != "" ? [
      {
        name  = "OTELContainerInsights.cloudwatchMetricsEndpoint"
        value = var.cloudwatch_metrics_endpoint
      },
    ] : [],
# TODO(launch): Remove cw_agent_image once GA chart is published.
# Only needed for internal pre-release testing.
    local.cw_agent_has_image_override ? concat(
      [
        {
          name  = "agent.image.repositoryDomainMap.public"
          value = local.cw_agent_image_domain
        },
        {
          name  = "agent.image.repository"
          value = local.cw_agent_image_repo
        },
      ],
      local.cw_agent_image_tag != "" ? [
        {
          name  = "agent.image.tag"
          value = local.cw_agent_image_tag
        },
      ] : [],
    ) : [],
  )
}
