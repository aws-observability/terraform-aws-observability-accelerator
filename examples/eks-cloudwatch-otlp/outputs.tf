output "collector_irsa_arn" {
  description = "IAM role ARN for the OTel Collector service account"
  value       = module.eks_monitoring.collector_irsa_arn
}

output "cloudwatch_promql_datasource_config" {
  description = "Grafana Prometheus datasource config for CloudWatch PromQL endpoint"
  value       = module.eks_monitoring.cloudwatch_promql_datasource_config
}

output "eks_cluster_id" {
  description = "EKS cluster identifier"
  value       = module.eks_monitoring.eks_cluster_id
}
