#--------------------------------------------------------------
# Profile Selection
#--------------------------------------------------------------

variable "collector_profile" {
  type        = string
  description = "Collector deployment profile: managed-metrics (AMP, agentless), self-managed-amp (AMP, OTel Collector), cloudwatch-otlp (CloudWatch, OTel Collector)"
  validation {
    condition     = contains(["managed-metrics", "self-managed-amp", "cloudwatch-otlp"], var.collector_profile)
    error_message = "collector_profile must be one of: managed-metrics, self-managed-amp, cloudwatch-otlp"
  }
}

#--------------------------------------------------------------
# Shared Variables (all profiles)
#--------------------------------------------------------------

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster identifier used for naming resources and looking up cluster data"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS OIDC provider for IRSA role creation. If empty, derived automatically from the EKS cluster."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created by this module"
  default     = {}
}

variable "enable_dashboards" {
  type        = bool
  description = "Whether to provision Grafana dashboards via the Grafana provider. Only applies when dashboard_delivery_method is terraform."
  default     = true
}

variable "dashboard_delivery_method" {
  type        = string
  description = "How dashboards are delivered: terraform (module provisions via grafana_dashboard) or none (skip, bring your own GitOps)."
  default     = "terraform"
  validation {
    condition     = contains(["terraform", "none"], var.dashboard_delivery_method)
    error_message = "dashboard_delivery_method must be one of: terraform, none"
  }
}

variable "dashboard_sources" {
  type        = map(string)
  description = "Map of dashboard names to JSON source URLs or local file paths. When empty, default dashboards are used."
  default     = {}
}

variable "dashboard_git_tag" {
  type        = string
  description = "Git tag used to construct default dashboard JSON URLs from the aws-observability-accelerator repository"
  default     = "v0.3.2"
}

variable "grafana_folder_id" {
  type        = string
  description = "Grafana folder ID to organize dashboards into a specific folder"
  default     = null
}

#--------------------------------------------------------------
# AMP Workspace Variables
#--------------------------------------------------------------

variable "create_amp_workspace" {
  type        = bool
  description = "Whether to create a new AMP workspace. When false, managed_prometheus_workspace_id must be provided."
  default     = true
}

variable "managed_prometheus_workspace_id" {
  type        = string
  description = "ID of an existing AMP workspace to use when create_amp_workspace is false"
  default     = null
}

variable "amp_workspace_alias" {
  type        = string
  description = "Alias for the AMP workspace when create_amp_workspace is true"
  default     = "eks-monitoring"
}

variable "enable_alerting_rules" {
  type        = bool
  description = "Whether to create Prometheus alerting rule group namespaces in the AMP workspace"
  default     = true
}

variable "enable_recording_rules" {
  type        = bool
  description = "Whether to create Prometheus recording rule group namespaces in the AMP workspace"
  default     = true
}

variable "custom_alerting_rules" {
  type        = string
  description = "Additional alerting rule group YAML to append to the default infrastructure alerting rules"
  default     = ""
}

variable "custom_recording_rules" {
  type        = string
  description = "Additional recording rule group YAML to append to the default infrastructure recording rules"
  default     = ""
}

#--------------------------------------------------------------
# Managed-Metrics Profile Variables
#--------------------------------------------------------------

variable "scraper_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the AMP Managed Collector scraper. Must contain at least 2 subnets in 2 distinct Availability Zones."
  default     = []
  validation {
    condition     = length(var.scraper_subnet_ids) == 0 || length(var.scraper_subnet_ids) >= 2
    error_message = "scraper_subnet_ids must contain at least 2 subnets in 2 distinct Availability Zones"
  }
}

variable "scraper_security_group_ids" {
  type        = list(string)
  description = "Security group IDs for the AMP Managed Collector scraper"
  default     = []
}

variable "scrape_configuration" {
  type        = string
  description = "Custom Prometheus scrape configuration YAML. When non-empty, overrides the default generated configuration."
  default     = ""
}

variable "additional_scrape_jobs" {
  type        = list(any)
  description = "Additional scrape job objects to append to the default scrape configuration"
  default     = []
}

variable "prometheus_config" {
  type = object({
    global_scrape_interval = optional(string, "60s")
    global_scrape_timeout  = optional(string, "15s")
  })
  description = "Global Prometheus scrape settings for the generated scrape configuration"
  default     = {}
}

#--------------------------------------------------------------
# OTel Collector Variables (self-managed-amp, cloudwatch-otlp)
#--------------------------------------------------------------

variable "otel_collector_chart_version" {
  type        = string
  description = "Version of the opentelemetry-collector Helm chart to deploy"
  default     = "0.78.0"
}

variable "kube_state_metrics_chart_version" {
  type        = string
  description = "Version of the kube-state-metrics Helm chart to deploy"
  default     = "5.15.2"
}

variable "node_exporter_chart_version" {
  type        = string
  description = "Version of the prometheus-node-exporter Helm chart to deploy"
  default     = "4.24.0"
}

variable "collector_namespace" {
  type        = string
  description = "Kubernetes namespace for the OTel Collector deployment"
  default     = "otel-collector"
}

variable "helm_values" {
  type        = map(string)
  description = "Additional Helm values to pass to the OTel Collector chart via dynamic set blocks"
  default     = {}
}

#--------------------------------------------------------------
# CloudWatch OTLP Variables (cloudwatch-otlp profile)
#--------------------------------------------------------------

variable "cloudwatch_metrics_endpoint" {
  type        = string
  description = "CloudWatch OTLP metrics endpoint URL for the cloudwatch-otlp profile"
  default     = ""
}

variable "cloudwatch_log_group" {
  type        = string
  description = "CloudWatch Logs log group name for the x-aws-log-group header in the OTLP logs exporter"
  default     = ""
}

variable "cloudwatch_log_stream" {
  type        = string
  description = "CloudWatch Logs log stream name for the x-aws-log-stream header in the OTLP logs exporter"
  default     = ""
}

variable "grafana_cw_datasource_name" {
  type        = string
  description = "Name for the Grafana Prometheus datasource pointing at the CloudWatch PromQL endpoint"
  default     = "CloudWatch PromQL"
}

#--------------------------------------------------------------
# Self-Managed AMP Toggles (self-managed-amp profile)
#--------------------------------------------------------------

variable "enable_tracing" {
  type        = bool
  description = "Whether to enable the traces pipeline in the self-managed-amp OTel Collector"
  default     = true
}

variable "enable_logs" {
  type        = bool
  description = "Whether to enable the logs pipeline in the self-managed-amp OTel Collector"
  default     = true
}
