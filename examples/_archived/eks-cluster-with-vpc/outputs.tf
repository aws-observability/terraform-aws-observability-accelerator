output "eks_cluster_id" {
  description = "EKS cluster name (use as eks_cluster_id in monitoring examples)"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "configure_kubectl" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
