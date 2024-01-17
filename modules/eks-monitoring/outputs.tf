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

output "ssmparameter_name_eks_monitoring" {
  description = "Name of the SSM Parameter"
  value       = module.external_secrets[0].ssmparameter_name
}

output "ssmparameter_arn_eks_monitoring" {
  description = "Name of the SSM Parameter"
  value       = module.external_secrets[0].ssmparameter_arn
}

output "kms_key_arn_eks_monitoring" {
  description = "Name of the SSM Parameter"
  value       = module.external_secrets[0].kms_key_arn_ssm
}
