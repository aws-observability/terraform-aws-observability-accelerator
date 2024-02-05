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

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = local.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = local.managed_prometheus_workspace_id
}

output "managed_prometheus_workspace_region" {
  description = "Amazon Managed Prometheus workspace region"
  value       = local.managed_prometheus_workspace_region
}

output "scraper_aws_auth" {
  description = "Execute this command to grand access to the managed scrapers to gain permissions on your cluster. Mandatory for the first use"
  value       = "eksctl create iamidentitymapping --cluster ${var.eks_cluster_id} --region ${local.managed_prometheus_workspace_region} --arn ${aws_prometheus_scraper.this.role_arn} --username aps-collector-user"
}
