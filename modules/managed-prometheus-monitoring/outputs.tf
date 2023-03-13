output "grafana_dashboard_urls" {
  value       = [grafana_dashboard.this.url]
  description = "URLs for dashboards created"
}
