output "grafana-workspace-endpoint" {
  description = "The Grafana Workspace endpoint"
  value       = aws_grafana_workspace.workshop.endpoint
}

output "grafana-workspace-id" {
  description = "The Grafana Workspace ID"
  value       = aws_grafana_workspace.workshop.id
}