variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "enable_amazon_eks_adot" {
  description = "Enables the ADOT Operator on the EKS Cluster"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Allow reusing an existing installation of cert-manager"
  type        = bool
  default     = true
}

variable "enable_managed_prometheus" {
  description = "Creates a new AMP workspace"
  type        = bool
  default     = true
}

variable "managed_prometheus_workspace_id" {
  description = "AMP Workspace ID"
  type        = string
  default     = ""
}

variable "managed_prometheus_workspace_region" {
  description = "Region where AMP is deployed"
  type        = string
  default     = null
}

variable "enable_alertmanager" {
  description = "Creates AMP AlertManager for all workloads"
  type        = bool
  default     = false
}

variable "enable_managed_grafana" {
  description = "Creates a new Amazon Managed Grafana (AMG) Workspace"
  type        = bool
  default     = true
}

variable "managed_grafana_region" {
  description = "Region where AMG is deployed"
  type        = string
  default     = null
}
variable "managed_grafana_workspace_id" {
  description = "AMG Workspace ID"
  type        = string
  default     = ""
}
variable "grafana_api_key" {
  description = "Grafana API key for the AMG workspace"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
