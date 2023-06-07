output "aws_region" {
  description = "AWS Region"
  value       = module.aws_observability_accelerator.aws_region
}

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = module.aws_observability_accelerator.managed_prometheus_workspace_id
}

output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks_monitoring.eks_cluster_version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_monitoring.eks_cluster_id
}
