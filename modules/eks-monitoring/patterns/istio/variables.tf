variable "pattern_config" {
  description = "Configuration object for ISTIO monitoring"
  type = object({
    enable_alerting_rules  = bool
    enable_recording_rules = bool
    scrape_sample_limit    = number

    enable_recording_rules = bool

    enable_dashboards = bool

    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    managed_prometheus_workspace_id       = string
    managed_prometheus_workspace_region   = string
    managed_prometheus_workspace_endpoint = string

    grafana_url                             = string
    grafana_istio_cp_dashboard_url          = string
    grafana_istio_mesh_dashboard_url        = string
    grafana_istio_performance_dashboard_url = string
    grafana_istio_service_dashboard_url     = string
  })
  nullable = false
}
