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

output "prometheus_data_source_created" {
  description = "Boolean value indicating if the module created a prometheus data source in Amazon Managed Grafana"
  value       = var.create_prometheus_data_source
}
