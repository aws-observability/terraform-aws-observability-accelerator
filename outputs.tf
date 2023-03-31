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

output "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = local.amg_ws_id
}

output "grafana_dashboards_folder_id" {
  description = "Grafana folder ID for automatic dashboards. Required by workload modules"
  value       = var.create_dashboard_folder ? grafana_folder.this[0].id : ""
}

output "grafana_prometheus_datasource_test" {
  description = "Grafana save & test URL for Amazon Managed Prometheus workspace"
  value       = var.create_grafana_data_source ? "${local.amg_ws_endpoint}/datasources/edit/${grafana_data_source.amp[0].uid}" : ""
}
