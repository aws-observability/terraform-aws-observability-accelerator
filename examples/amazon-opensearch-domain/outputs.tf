################################################################################
# Domain
################################################################################

output "domain_arn" {
  description = "The Amazon Resource Name (ARN) of the domain"
  value       = module.opensearch.domain_arn
}

output "domain_id" {
  description = "The unique identifier for the domain"
  value       = module.opensearch.domain_id
}

output "domain_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.opensearch.domain_endpoint
}

output "domain_dashboard_endpoint" {
  description = "Domain-specific endpoint for Dashboard without https scheme"
  value       = module.opensearch.domain_dashboard_endpoint
}

################################################################################
# Package Association(s)
################################################################################

output "package_associations" {
  description = "Map of package associations created and their attributes"
  value       = module.opensearch.package_associations
}

################################################################################
# VPC Endpoint(s)
################################################################################

output "vpc_endpoints" {
  description = "Map of VPC endpoints created and their attributes"
  value       = module.opensearch.vpc_endpoints
}

################################################################################
# Outbound Connections
################################################################################

output "outbound_connections" {
  description = "Map of outbound connections created and their attributes"
  value       = module.opensearch.outbound_connections
}

################################################################################
# CloudWatch Log Groups
################################################################################

output "cloudwatch_logs" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.opensearch.cloudwatch_logs
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.opensearch.security_group_arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.opensearch.security_group_id
}
