variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-with-vpc"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "managed_prometheus_workspace_id" {
  description = "Amazon Managed Service for Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  sensitive   = true
}

variable "enable_dashboards" {
  description = "Enables or disables curated dashboards. Dashboards are managed by the Grafana Operator"
  type        = bool
  default     = true
}

variable "istio_chart_url" {
  description = "Helm repository for Tetrate Istio charts"
  type        = string
  default     = "https://tis.tetrate.io/charts"
}

variable "istio_chart_version" {
  description = "Helm chart version for Tetrate Istio charts"
  type        = string
  default     = "1.20.1"
}

variable "istio_global_tag" {
  description = "Tetrate Istio container tag"
  type        = string
  default     = "1.20.1-tetrate0"
}

variable "istio_global_hub" {
  description = "Tetrate Istio container repository"
  type        = string
  default     = "containers.istio.tetratelabs.com"
}
