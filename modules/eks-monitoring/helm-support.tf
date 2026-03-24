#--------------------------------------------------------------
# kube-state-metrics (AMP profiles only)
#
# The CW Agent chart bundles its own kube-state-metrics, so
# these are only needed for managed-metrics and self-managed-amp.
#--------------------------------------------------------------

resource "helm_release" "kube_state_metrics" {
  count = local.needs_helm_support ? 1 : 0

  name             = "kube-state-metrics"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-state-metrics"
  version          = var.kube_state_metrics_chart_version
  namespace        = "kube-system"
  create_namespace = false
  max_history      = 3
}

#--------------------------------------------------------------
# prometheus-node-exporter (AMP profiles only)
#--------------------------------------------------------------

resource "helm_release" "prometheus_node_exporter" {
  count = local.needs_helm_support ? 1 : 0

  name             = "prometheus-node-exporter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-node-exporter"
  version          = var.node_exporter_chart_version
  namespace        = "prometheus-node-exporter"
  create_namespace = true
  max_history      = 3
}
