output "grafana_dashboard_urls" {
  value = [concat(
    grafana_dashboard.cluster[*].url,
    grafana_dashboard.istiocontrolplanedashboard[*].url,
    grafana_dashboard.istiomeshdashboard[*].url,
    grafana_dashboard.istioperformancedashboard[*].url,
    grafana_dashboard.istioservicedashboard[*].url
  )]
  description = "URLs for dashboards created"
}