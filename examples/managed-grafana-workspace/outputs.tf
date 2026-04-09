output "grafana_workspace_endpoint" {
  description = "Amazon Managed Grafana workspace URL (pass as grafana_endpoint to monitoring examples)"
  value       = "https://${module.managed_grafana.workspace_endpoint}"
}

output "grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = module.managed_grafana.workspace_id
}

output "grafana_workspace_iam_role_arn" {
  description = "Amazon Managed Grafana workspace IAM role ARN"
  value       = module.managed_grafana.workspace_iam_role_arn
}

output "grafana_api_key" {
  description = "Grafana service account token (30-day TTL, pass as grafana_api_key to monitoring examples)"
  value       = aws_grafana_workspace_service_account_token.terraform.key
  sensitive   = true
}
