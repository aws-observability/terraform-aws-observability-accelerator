output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = var.eks_cluster_id
}

output "aws_region" {
  description = "EKS Cluster Id"
  value       = var.aws_region
}

output "eks_cluster_version" {
  value = data.aws_eks_cluster.eks_cluster.version
}

output "managed_prometheus_workspace_endpoint" {
  value = local.amp_ws_endpoint
}

output "managed_prometheus_workspace_id" {
  value = local.amp_ws_id
}

output "managed_prometheus_workspace_region" {
  value = local.amp_ws_region
}

output "managed_grafana_workspace_endpoint" {
  value = local.amg_ws_endpoint
}

output "grafana_dashboards_folder_id" {
  value = grafana_folder.this.id
}
