variable "helm_config" {
  description = "Helm provider config for external secrets"
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
    irsa_iam_permissions_boundary  = string
    tags                           = map(string)
  })
}

variable "enable_external_secrets" {
  description = "Enable external-secrets"
  type        = bool
  default     = true
}

variable "grafana_api_key" {
  description = "Grafana API key for the Amazon Managed Grafana workspace"
  type        = string
}

variable "target_secret_namespace" {
  description = "Namespace to store the secret for Grafana API Key"
  type        = string
}

variable "target_secret_name" {
  description = "Name to store the secret for Grafana API Key"
  type        = string
}
