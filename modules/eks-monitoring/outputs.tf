output "grafana_dashboard_urls" {
  value = [concat(
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
