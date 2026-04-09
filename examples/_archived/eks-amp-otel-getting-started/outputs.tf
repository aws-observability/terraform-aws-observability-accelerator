output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = module.eks_monitoring.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = module.eks_monitoring.managed_prometheus_workspace_id
}

output "managed_prometheus_workspace_region" {
  description = "Amazon Managed Prometheus workspace region"
  value       = module.eks_monitoring.managed_prometheus_workspace_region
}

output "collector_irsa_arn" {
  description = "IRSA role ARN for the OTel Collector service account"
  value       = module.eks_monitoring.collector_irsa_arn
}

output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks_monitoring.eks_cluster_id
}
