output "cloudwatch_promql_datasource" {
  description = "CloudWatch PromQL datasource configuration for Grafana"
  value       = module.eks_monitoring.cloudwatch_promql_datasource_config
}

output "otlp_gateway_endpoint" {
  description = "OTLP gateway endpoint for application telemetry"
  value       = module.eks_monitoring.otlp_gateway_endpoint
}

output "collector_irsa_arn" {
  description = "IRSA role ARN for the OTel Collector"
  value       = module.eks_monitoring.collector_irsa_arn
}
