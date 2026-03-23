output "grafana_workspace_endpoint" {
  description = "Amazon Managed Grafana workspace URL"
  value       = "https://${module.managed_grafana.workspace_endpoint}"
}

output "grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = module.managed_grafana.workspace_id
}

output "grafana_api_key" {
  description = "Grafana service account token for dashboard provisioning"
  value       = aws_grafana_workspace_service_account_token.terraform.key
  sensitive   = true
}

output "collector_irsa_arn" {
  description = "IAM role ARN for the OTel Collector service account"
  value       = module.eks_monitoring.collector_irsa_arn
}

output "cloudwatch_promql_datasource_config" {
  description = "Grafana Prometheus datasource config for CloudWatch PromQL endpoint"
  value       = module.eks_monitoring.cloudwatch_promql_datasource_config
}

output "eks_cluster_id" {
  description = "EKS cluster identifier"
  value       = module.eks_monitoring.eks_cluster_id
}
