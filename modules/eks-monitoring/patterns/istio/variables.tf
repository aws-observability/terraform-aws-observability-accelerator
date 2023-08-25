variable "pattern_config" {
  description = "Configuration object for ISTIO monitoring"
  type = object({
    enable_alerting_rules  = bool
    enable_recording_rules = bool
    enable_dashboards      = bool
    scrape_sample_limit    = number

    flux_gitrepository_name   = string
    flux_gitrepository_url    = string
    flux_gitrepository_branch = string
    flux_kustomization_name   = string
    flux_kustomization_path   = string

    managed_prometheus_workspace_id = string
    prometheus_metrics_endpoint     = string

    dashboards = object({
      cp          = string
      mesh        = string
      performance = string
      service     = string
    })
  })
  nullable = false
}
