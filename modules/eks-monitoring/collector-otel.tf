#--------------------------------------------------------------
# OTel Collector Helm Release (self-managed-amp, cloudwatch-otlp)
#--------------------------------------------------------------

resource "helm_release" "otel_collector" {
  count = local.needs_otel_helm ? 1 : 0

  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = var.otel_collector_chart_version
  namespace  = var.collector_namespace

  create_namespace = true

  values = [local.otel_collector_values]

  set = [for k, v in var.helm_values : { name = k, value = v }]

  depends_on = [
    module.collector_irsa_role,
  ]
}
