output "grafana_dashboard_urls" {
  value = [concat(
    grafana_dashboard.this[*].url,
  )]
  description = "URLs for dashboards created"
}
