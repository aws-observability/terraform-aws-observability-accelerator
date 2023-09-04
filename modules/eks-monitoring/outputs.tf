output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = data.aws_eks_cluster.eks_cluster.version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = var.eks_cluster_id
}

output "adot_irsa_arn" {
  description = "IRSA Arn for ADOT"
  value       = module.helm_addon.irsa_arn
}
