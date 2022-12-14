variable "helm_config" {
  description = "Helm provider config for cert-manager"
  type        = any
  default     = { version = "v1.8.2" }
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
    irsa_iam_permissions_boundary  = string
    tags                           = map(string)
  })
}

variable "enable_cert_manager" {
  description = "Enable cert-manager, a requirement for ADOT Operator"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "EKS Cluster version"
  type        = string
}

variable "addon_config" {
  description = "Amazon EKS Managed ADOT Add-on config"
  type        = any
  default     = {}
}
