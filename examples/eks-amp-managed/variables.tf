variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "scraper_subnet_ids" {
  description = "Subnet IDs for the AMP scraper (minimum 2 in 2 AZs)"
  type        = list(string)
}

variable "scraper_security_group_ids" {
  description = "Security group IDs for the AMP scraper"
  type        = list(string)
}

variable "grafana_endpoint" {
  description = "Amazon Managed Grafana workspace endpoint URL"
  type        = string
}

variable "grafana_api_key" {
  description = "Grafana API key for dashboard provisioning"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
