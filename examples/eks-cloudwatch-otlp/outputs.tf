output "cloudwatch_promql_datasource" {
  description = "CloudWatch PromQL datasource configuration for Grafana"
  value       = module.eks_monitoring.cloudwatch_promql_datasource_config
}

output "collector_irsa_arn" {
  description = "IRSA role ARN for the OTel Collector"
  value       = module.eks_monitoring.collector_irsa_arn
}
