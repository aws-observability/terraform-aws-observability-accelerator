#--------------------------------------------------------------
# kube-state-metrics
# Deployed for all profiles: managed-metrics needs it for scraper
# discovery, self-managed-amp and cloudwatch-otlp need it for
# the OTel Collector's Prometheus receiver.
#--------------------------------------------------------------

resource "helm_release" "kube_state_metrics" {
  count = 1

  name             = "kube-state-metrics"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-state-metrics"
  version          = "5.15.2"
  namespace        = "kube-system"
  create_namespace = false
  max_history      = 3
}

#--------------------------------------------------------------
# prometheus-node-exporter
# Deployed for all profiles for the same reasons as above.
#--------------------------------------------------------------

resource "helm_release" "prometheus_node_exporter" {
  count = 1

  name             = "prometheus-node-exporter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-node-exporter"
  version          = "4.24.0"
  namespace        = "prometheus-node-exporter"
  create_namespace = true
  max_history      = 3
}
