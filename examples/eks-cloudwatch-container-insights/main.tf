locals {
  cw_agent_use_local_chart = var.cw_agent_chart_path != ""

  cw_agent_has_image = var.cw_agent_image != ""
  cw_agent_parts     = local.cw_agent_has_image ? regex("^(.+?)(?::([^/]+))?$", var.cw_agent_image) : ["", ""]
  cw_agent_image_ref = local.cw_agent_parts[0]
  cw_agent_image_tag = local.cw_agent_parts[1] != null ? local.cw_agent_parts[1] : ""
  cw_agent_domain    = local.cw_agent_has_image ? regex("^([^/]+)/(.+)$", local.cw_agent_image_ref)[0] : ""
  cw_agent_repo      = local.cw_agent_has_image ? regex("^([^/]+)/(.+)$", local.cw_agent_image_ref)[1] : ""
}

#--------------------------------------------------------------
# CloudWatch Agent (Container Insights with OTel)
#--------------------------------------------------------------

resource "helm_release" "cloudwatch_agent" {
  name       = "amazon-cloudwatch"
  repository = local.cw_agent_use_local_chart ? null : "https://aws.github.io/eks-charts"
  chart      = local.cw_agent_use_local_chart ? var.cw_agent_chart_path : "amazon-cloudwatch-observability"
  namespace  = "amazon-cloudwatch"

  create_namespace = true
  max_history      = 3

  set = concat(
    [
      { name = "clusterName", value = var.eks_cluster_id },
      { name = "region", value = var.aws_region },
      { name = "OTELContainerInsights.enabled", value = "true" },
      { name = "containerInsights.enabled", value = "false" },
      { name = "containerLogs.enabled", value = "true" },
    ],
    var.cloudwatch_metrics_endpoint != "" ? [
      { name = "OTELContainerInsights.cloudwatchMetricsEndpoint", value = var.cloudwatch_metrics_endpoint },
    ] : [],
    local.cw_agent_has_image ? concat(
      [
        { name = "agent.image.repositoryDomainMap.public", value = local.cw_agent_domain },
        { name = "agent.image.repository", value = local.cw_agent_repo },
      ],
      local.cw_agent_image_tag != "" ? [
        { name = "agent.image.tag", value = local.cw_agent_image_tag },
      ] : [],
    ) : [],
  )
}
