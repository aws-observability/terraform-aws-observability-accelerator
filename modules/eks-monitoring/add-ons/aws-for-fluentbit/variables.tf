variable "helm_config" {
  description = "Helm provider config aws_for_fluent_bit."
  type        = any
  default     = {}
}

variable "cw_log_retention_days" {
  description = "FluentBit CloudWatch Log group retention period"
  type        = number
  default     = 90
}

variable "refresh_interval" {
  description = "FluentBit input refresh interval"
  type        = number
  default     = 60
}


variable "manage_via_gitops" {
  type        = bool
  description = "Determines if the add-on should be managed via GitOps."
  default     = false
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
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
    tags                           = map(string)
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}
