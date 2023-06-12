output "aws_region" {
  description = "AWS Region"
  value       = module.aws_observability_accelerator.aws_region
}

output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks_monitoring.eks_cluster_version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_monitoring.eks_cluster_id
}
