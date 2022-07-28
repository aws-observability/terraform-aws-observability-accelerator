output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_observability_accelerator.eks_cluster_id
}

output "aws_region" {
  description = "AWS Region"
  value       = module.eks_observability_accelerator.aws_region
}

output "eks_cluster_version" {
  value = module.eks_observability_accelerator.eks_cluster_version
}


output "prometheus_endpoint" {
  value = module.eks_observability_accelerator.prometheus_endpoint
}

output "prometheus_id" {
  value = module.eks_observability_accelerator.prometheus_id
}
