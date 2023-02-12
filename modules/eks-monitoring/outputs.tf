output "grafana_dashboard_urls" {
  value = [concat(
    grafana_dashboard.workloads[*].url,
    grafana_dashboard.nodes[*].url,
    grafana_dashboard.nsworkload[*].url,
    grafana_dashboard.kubelet[*].url,
    grafana_dashboard.cluster[*].url,
    flatten(module.java_monitoring[*].grafana_dashboard_urls),
    flatten(module.nginx_monitoring[*].grafana_dashboard_urls),
  )]
  description = "URLs for dashboards created"
}
