output "grafana_workspace_endpoint" {
  description = "The Grafana Workspace endpoint"
  value       = aws_grafana_workspace.workshop.endpoint
}

output "grafana_workspace_id" {
  description = "The Grafana Workspace ID"
  value       = aws_grafana_workspace.workshop.id
}