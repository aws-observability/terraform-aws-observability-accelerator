output "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = try(module.managed_grafana_default[0].workspace_id, "")
}

output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = try(module.managed_grafana_default[0].workspace_endpoint, "")
}

output "prometheus_workspace_id" {
  description = "Identifier of the workspace"
  value       = try(module.managed_prometheus_default[0].id, "")
}

output "prometheus_workspace_prometheus_endpoint" {
  description = "Prometheus endpoint available for this workspace"
  value       = try(module.managed_prometheus_default[0].prometheus_endpoint, "")
}
