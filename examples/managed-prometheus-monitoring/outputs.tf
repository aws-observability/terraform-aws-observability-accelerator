output "grafana_dashboard_urls" {
  description = "URLs for dashboards created"
  value       = module.managed_prometheus_monitoring.grafana_dashboard_urls
}
