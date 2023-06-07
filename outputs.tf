output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = local.amp_ws_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = local.amp_ws_id
}

output "managed_prometheus_workspace_region" {
  description = "Amazon Managed Prometheus workspace region"
  value       = local.amp_ws_region
}

output "managed_grafana_workspace_endpoint" {
  description = "Amazon Managed Grafana workspace endpoint"
  value       = local.amg_ws_endpoint
}
