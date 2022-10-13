variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana (AMG) workspace ID"
  type        = string
  default     = ""
}

variable "enable_managed_grafana" {
  description = "Creates a new Amazon Managed Grafana Workspace"
  type        = bool
  default     = true
}