#--------------------------------------------------------------
# AMP Workspace Outputs
#--------------------------------------------------------------

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint URL"
  value       = local.amp_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = local.amp_workspace_id
}

output "managed_prometheus_workspace_region" {
  description = "Amazon Managed Prometheus workspace region"
  value       = local.region
}

#--------------------------------------------------------------
# Collector Outputs
#--------------------------------------------------------------

output "collector_irsa_arn" {
  description = "IRSA role ARN for the OTel Collector service account (self-managed profiles only)"
  value       = local.needs_irsa ? try(module.collector_irsa_role[0].iam_role_arn, null) : null
}

output "amp_scraper_arn" {
  description = "ARN of the AMP Managed Collector scraper (managed-metrics profile only)"
  value       = local.is_managed_metrics ? try(aws_prometheus_scraper.this[0].arn, null) : null
}

#--------------------------------------------------------------
# Cluster Output
#--------------------------------------------------------------

output "eks_cluster_id" {
  description = "EKS cluster identifier"
  value       = var.eks_cluster_id
}

#--------------------------------------------------------------
# CloudWatch PromQL Datasource Output
#--------------------------------------------------------------

output "cloudwatch_promql_datasource_config" {
  description = "Configuration for Grafana Prometheus datasource pointing at CloudWatch PromQL endpoint (cloudwatch-otlp profile only)"
  value = local.is_cloudwatch_otlp ? {
    endpoint      = var.cloudwatch_metrics_endpoint
    sigv4_region  = local.region
    sigv4_service = "monitoring"
    type          = "prometheus"
    http_method   = "POST"
  } : null
}
