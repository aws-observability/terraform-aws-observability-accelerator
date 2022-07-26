variable "helm_config" {
  description = "Helm provider config for ADOT Operator AddOn"
  type        = any
  default     = {}
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    irsa_iam_role_path             = string
    tags                           = map(string)
  })
}

variable "kubernetes_version" {
  type = string
}

variable "addon_config" {
  description = "Amazon EKS Managed CoreDNS Add-on config"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_adot" {
  description = "Enable Amazon EKS ADOT add-on"
  type        = bool
  default     = true
}

variable "enable_opentelemetry_operator" {
  description = "Enable opentelemetry operator addon"
  type        = bool
  default     = false
}
