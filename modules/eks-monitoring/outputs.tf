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
output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = data.aws_eks_cluster.eks_cluster.version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = var.eks_cluster_id
}
