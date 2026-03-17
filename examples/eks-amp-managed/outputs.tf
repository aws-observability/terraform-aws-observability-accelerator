output "managed_prometheus_workspace_endpoint" {
  description = "AMP workspace endpoint URL"
  value       = module.eks_monitoring.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "AMP workspace ID"
  value       = module.eks_monitoring.managed_prometheus_workspace_id
}

output "amp_scraper_arn" {
  description = "ARN of the AMP Managed Collector scraper"
  value       = module.eks_monitoring.amp_scraper_arn
}

output "eks_cluster_id" {
  description = "EKS cluster identifier"
  value       = module.eks_monitoring.eks_cluster_id
}
