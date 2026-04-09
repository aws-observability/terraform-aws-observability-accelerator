variable "eks_cluster_id" {
  description = "Name of the EKS cluster"
  default     = "eks-cw"
  type        = string
}

variable "enable_amazon_eks_cw_observability" {
  description = "Enable Amazon EKS CloudWatch Observability add-on"
  type        = bool
  default     = true
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
  description = "Determines if the most recent or default version of the addon should be returned."
  type        = bool
  default     = false
}

variable "eks_oidc_provider_arn" {
  description = "The OIDC Provider ARN of AWS EKS cluster"
  type        = string
  default     = ""
}

variable "create_cloudwatch_observability_irsa_role" {
  type        = bool
  default     = true
  description = "Create a Cloudwatch Observability IRSA"
}

variable "create_cloudwatch_application_signals_role" {
  type        = bool
  default     = true
  description = "Create a Cloudwatch Application Signals service-linked role"
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
