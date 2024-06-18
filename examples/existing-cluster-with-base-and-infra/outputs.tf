output "managed_prometheus_workspace_region" {
  description = "AWS Region"
  value       = module.eks_monitoring.managed_prometheus_workspace_region
}

output "managed_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus workspace endpoint"
  value       = module.eks_monitoring.managed_prometheus_workspace_endpoint
}

output "managed_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus workspace ID"
  value       = module.eks_monitoring.managed_prometheus_workspace_id
}

output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks_monitoring.eks_cluster_version
}

output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = module.eks_monitoring.eks_cluster_id
}

output "grafana_key_rotation_lambda_function_arn" {
  description = "ARN of the Lambda function performing Key rotation"
  # value       = module.grafana_key_rotation.lambda_function_arn
  value = var.enable_grafana_key_rotation ? module.grafana_key_rotation[0].lambda_function_arn : null
}


output "grafana_key_rotation_lambda_function_role_arn" {
  description = "ARN of the Lambda function execution role"
  # value       = module.grafana_key_rotation.lambda_function_role_arn
  value = var.enable_grafana_key_rotation ? module.grafana_key_rotation[0].lambda_function_role_arn : null
}


output "grafana_key_rotation_eventbridge_scheduler_arn" {
  description = "ARN of the EventBridge Scheduler invoking Lambda Function for Key rotation"
  # value       = module.grafana_key_rotation.eventbridge_scheduler_arn
  value = var.enable_grafana_key_rotation ? module.grafana_key_rotation[0].eventbridge_scheduler_arn : null
}


output "grafana_key_rotation_eventbridge_scheduler_role_arn" {
  description = "ARN of the IAM Role of EventBridge Scheduler invoking Lambda Function for Key rotation"
  # value       = module.grafana_key_rotation.eventbridge_scheduler_role_arn
  value = var.enable_grafana_key_rotation ? module.grafana_key_rotation[0].eventbridge_scheduler_role_arn : null
}
