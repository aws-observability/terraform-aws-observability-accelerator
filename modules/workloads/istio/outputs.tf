output "grafana_dashboard_urls" {
  value = [concat(
    grafana_dashboard.workloads.*.url,
    grafana_dashboard.istiomeshdashboard.*.url,
    grafana_dashboard.istioservicedashboard.*.url,
    grafana_dashboard.istiocontrolplanedashboard.*.url,
    grafana_dashboard.istioperformancedashboard.*.url,
    grafana_dashboard.cluster.*.url,
  )]
  description = "URLs for dashboards created"
}
