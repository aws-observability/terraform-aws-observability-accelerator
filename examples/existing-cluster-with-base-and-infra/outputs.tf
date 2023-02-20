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

output "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana workspace ID"
  value       = module.aws_observability_accelerator.managed_grafana_workspace_id
}

output "grafana_dashboard_urls" {
  description = "URLs for dashboards created"
  value       = module.eks_monitoring.grafana_dashboard_urls
}

output "grafana_prometheus_datasource_test" {
  description = "Grafana save & test URL for Amazon Managed Prometheus workspace"
  value       = module.aws_observability_accelerator.grafana_prometheus_datasource_test
}
output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks_monitoring.eks_cluster_version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_monitoring.eks_cluster_id
}
