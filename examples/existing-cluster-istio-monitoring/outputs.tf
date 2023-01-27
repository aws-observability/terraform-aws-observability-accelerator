output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_observability_accelerator.eks_cluster_id
}

output "aws_region" {
  description = "AWS Region"
  value       = module.eks_observability_accelerator.aws_region
}

output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks_observability_accelerator.eks_cluster_version
}

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = module.eks_observability_accelerator.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = module.eks_observability_accelerator.managed_prometheus_workspace_id
}

output "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = module.eks_observability_accelerator.managed_grafana_workspace_id
}

output "grafana_dashboard_urls" {
  description = "URLs for dashboards created"
  value       = module.workloads_istio.grafana_dashboard_urls
}
