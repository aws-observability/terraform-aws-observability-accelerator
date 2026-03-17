#--------------------------------------------------------------
# Grafana Dashboard Provisioning
#--------------------------------------------------------------

data "http" "dashboard_json" {
  for_each = local.provision_dashboards ? local.dashboard_sources : {}
  url      = each.value
}

resource "grafana_dashboard" "this" {
  for_each = local.provision_dashboards ? local.dashboard_sources : {}

  config_json = data.http.dashboard_json[each.key].response_body
  folder      = var.grafana_folder_id
  overwrite   = true
}

#--------------------------------------------------------------
# CloudWatch PromQL Datasource (cloudwatch-otlp profile)
#--------------------------------------------------------------

resource "grafana_data_source" "cloudwatch_promql" {
  count = local.is_cloudwatch_otlp && local.provision_dashboards ? 1 : 0

  type = "grafana-amazonprometheus-datasource"
  name = var.grafana_cw_datasource_name
  url  = var.cloudwatch_metrics_endpoint

  json_data_encoded = jsonencode({
    httpMethod    = "POST"
    sigV4Auth     = true
    sigV4Region   = local.region
    sigV4Service  = "monitoring"
  })
}
