output "grafana_workspace_endpoint" {
  description = "Amazon Managed Grafana Workspace endpoint"
  value       = "https://${module.managed_grafana.workspace_endpoint}"
}

output "grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  value       = module.managed_grafana.workspace_id
}

output "grafana_workspace_iam_role_arn" {
  description = "Amazon Managed Grafana Workspace's IAM Role ARN"
  value       = module.managed_grafana.workspace_iam_role_arn
}
