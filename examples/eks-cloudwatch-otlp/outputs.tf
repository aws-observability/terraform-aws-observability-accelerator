output "grafana_workspace_endpoint" {
  description = "Amazon Managed Grafana workspace URL"
  value       = module.managed_grafana.workspace_endpoint
}

output "grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = module.managed_grafana.workspace_id
}

output "grafana_api_key" {
  description = "Grafana service account token (30-day TTL)"
  value       = aws_grafana_workspace_service_account_token.terraform.key
  sensitive   = true
}

output "cloudwatch_promql_datasource" {
  description = "CloudWatch PromQL datasource configuration for Grafana"
  value       = module.eks_monitoring.cloudwatch_promql_datasource_config
}

output "cw_agent_namespace" {
  description = "Kubernetes namespace where the CloudWatch Agent is deployed"
  value       = module.eks_monitoring.cw_agent_namespace
}
