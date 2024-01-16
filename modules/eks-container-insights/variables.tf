variable "cluster_name" {
  default = "eks-cw"
  type    = string
}

variable "enable_amazon_eks_cw_observability" {
  description = "Enable Amazon EKS CloudWatch Observability add-on"
  type        = bool
  default     = false
}

variable "addon_config" {
  description = "Amazon EKS Managed CloudWatch Observability Add-on config"
  type        = any
  default     = {}
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "most_recent" {
  type    = string
  default = "false"
}

variable "eks_oidc_provider_arn" {
  type    = string
  default = ""
}

variable "create_cloudwatch_observability_irsa_role" {
  type        = string
  default     = true
  description = "Create a Cloudwatch Observability IRSA"
}

variable "create_cloudwatch_application_signals_role" {
  type        = string
  default     = true
  description = "Create a Cloudwatch Application Signals service-linked role"
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}