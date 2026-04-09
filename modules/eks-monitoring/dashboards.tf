#--------------------------------------------------------------
# Grafana Dashboard Folder
#--------------------------------------------------------------

resource "grafana_folder" "this" {
  count = local.provision_dashboards && var.grafana_folder_id == null ? 1 : 0

  title = local.is_cloudwatch_otlp ? "CloudWatch Container Insights" : "EKS Monitoring"
}

locals {
  grafana_folder_id = var.grafana_folder_id != null ? var.grafana_folder_id : (
    local.provision_dashboards ? grafana_folder.this[0].id : null
  )

  # Split dashboard sources into HTTP URLs vs local file paths
  http_dashboard_sources  = { for k, v in local.dashboard_sources : k => v if startswith(v, "http") }
  local_dashboard_sources = { for k, v in local.dashboard_sources : k => v if !startswith(v, "http") }
}

#--------------------------------------------------------------
# Grafana Dashboard Provisioning
#--------------------------------------------------------------

data "http" "dashboard_json" {
  for_each = local.provision_dashboards ? local.http_dashboard_sources : {}
  url      = each.value
}

resource "grafana_dashboard" "http" {
  for_each = local.provision_dashboards ? local.http_dashboard_sources : {}

  config_json = data.http.dashboard_json[each.key].response_body
  folder      = local.grafana_folder_id
  overwrite   = true
}

resource "grafana_dashboard" "local" {
  for_each = local.provision_dashboards ? local.local_dashboard_sources : {}

  config_json = file(each.value)
  folder      = local.grafana_folder_id
  overwrite   = true
}

#--------------------------------------------------------------
# CloudWatch PromQL Datasource (cloudwatch-otlp profile)
#--------------------------------------------------------------

resource "grafana_data_source" "cloudwatch_promql" {
  count = local.is_cloudwatch_otlp && local.provision_dashboards ? 1 : 0

  type = "prometheus"
  name = var.grafana_cw_datasource_name
  url  = "https://monitoring.${local.region}.amazonaws.com"

  json_data_encoded = jsonencode({
    httpMethod     = "POST"
    sigV4Auth      = true
    sigV4AuthType  = "ec2_iam_role"
    sigV4Region    = local.region
    sigV4Service   = "monitoring"
  })
}

#--------------------------------------------------------------
# Datasource Health Check (equivalent to "Save & Test" in UI)
#--------------------------------------------------------------

resource "terraform_data" "validate_cw_datasource" {
  count = local.is_cloudwatch_otlp && local.provision_dashboards && var.grafana_endpoint != "" ? 1 : 0

  triggers_replace = grafana_data_source.cloudwatch_promql[0].uid

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      for i in 1 2 3; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%%{http_code}" \
          -H "Authorization: Bearer $GRAFANA_API_KEY" \
          "$GRAFANA_URL/api/datasources/uid/$DS_UID/health")
        if [ "$HTTP_CODE" = "200" ]; then
          echo "Datasource health check passed"
          exit 0
        fi
        echo "Attempt $i: HTTP $HTTP_CODE, retrying in 5s..."
        sleep 5
      done
      echo "WARNING: Datasource health check did not return 200 after 3 attempts"
      exit 0
    EOT
    environment = {
      GRAFANA_URL     = var.grafana_endpoint
      GRAFANA_API_KEY = var.grafana_api_key
      DS_UID          = grafana_data_source.cloudwatch_promql[0].uid
    }
  }
}
