resource "kubectl_manifest" "flux_gitrepository" {
  count = var.enable_dashboards ? 1 : 0

  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: ${var.flux_gitrepository_name}
  namespace: flux-system
spec:
  interval: 5m0s
  url: ${var.flux_gitrepository_url}
  ref:
    branch: ${var.flux_gitrepository_branch}
YAML

  depends_on = [module.external_secrets]
}

resource "kubectl_manifest" "flux_kustomization" {
  yaml_body  = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: ${var.flux_kustomization_name}
  namespace: flux-system
spec:
  interval: 1m0s
  path: ${var.flux_kustomization_path}
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${var.flux_gitrepository_name}
  postBuild:
    substitute:
      AMG_AWS_REGION: ${var.managed_prometheus_workspace_region}
      AMP_ENDPOINT_URL: ${var.managed_prometheus_workspace_endpoint}
      AMG_ENDPOINT_URL: ${var.grafana_url}
      GRAFANA_CLUSTER_DASH_URL: ${var.grafana_cluster_dashboard_url}
      GRAFANA_APISERVER_BASIC_DASH_URL: ${var.grafana_apiserver_basic_dashboard_url}
      GRAFANA_APISERVER_ADVANCED_DASH_URL: ${var.grafana_apiserver_advanced_dashboard_url}
      GRAFANA_KUBELET_DASH_URL: ${var.grafana_kubelet_dashboard_url}
      GRAFANA_NSWRKLDS_DASH_URL: ${var.grafana_namespace_workloads_dashboard_url}
      GRAFANA_NODEEXP_DASH_URL: ${var.grafana_node_exporter_dashboard_url}
      GRAFANA_NODES_DASH_URL: ${var.grafana_nodes_dashboard_url}
      GRAFANA_WORKLOADS_DASH_URL: ${var.grafana_workloads_dashboard_url}
YAML
  count      = var.enable_dashboards ? 1 : 0
  depends_on = [module.external_secrets]
}
