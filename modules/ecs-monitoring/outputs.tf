output "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = module.managed_grafana_default.workspace_id
}

output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = module.managed_grafana_default.workspace_endpoint
}

output "prometheus_workspace_id" {
  description = "Identifier of the workspace"
  value       = module.managed_prometheus_default.workspace_id
}

output "prometheus_workspace_endpoint" {
  description = "Prometheus endpoint available for this workspace"
  value       = module.managed_prometheus_default.workspace_prometheus_endpoint
}
