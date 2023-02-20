output "grafana_dashboard_urls" {
  value       = [concat(grafana_dashboard.workloads[*].url)]
  description = "URLs for dashboards created"
}
