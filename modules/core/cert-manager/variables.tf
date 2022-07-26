variable "helm_config" {
  description = "cert-manager Helm chart configuration"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "irsa_policies" {
  description = "Additional IAM policies used for the add-on service account."
  type        = list(string)
  default     = []
}

variable "domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager."
  type        = list(string)
  default     = []
}

variable "install_letsencrypt_issuers" {
  description = "Install Let's Encrypt Cluster Issuers."
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email address for expiration emails from Let's Encrypt."
  type        = string
  default     = ""
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
  })
}
