output "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = module.managed_grafana_default.workspace_id
}

output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = module.managed_grafana_default.workspace_endpoint
}
