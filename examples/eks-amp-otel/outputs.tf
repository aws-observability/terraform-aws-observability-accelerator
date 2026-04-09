output "managed_prometheus_workspace_endpoint" {
  description = "AMP workspace endpoint URL"
  value       = module.eks_monitoring.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "AMP workspace ID"
  value       = module.eks_monitoring.managed_prometheus_workspace_id
}

output "collector_irsa_arn" {
  description = "IAM role ARN for the OTel Collector service account"
  value       = module.eks_monitoring.collector_irsa_arn
}

output "eks_cluster_id" {
  description = "EKS cluster identifier"
  value       = module.eks_monitoring.eks_cluster_id
}
