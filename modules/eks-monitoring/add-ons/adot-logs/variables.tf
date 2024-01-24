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

variable "addon_config" {
  description = "ADOT Container Logs Collector config"
  type = object({
    enable_logs = bool
    logs_config = object({
      cw_log_retention_days = number
    })
  })
  default = {
    enable_logs = true
    logs_config = {
      cw_log_retention_days = 90
    }
  }
}
