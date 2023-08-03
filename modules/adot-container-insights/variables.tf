variable "helm_config" {
  description = "Helm provider config for adot-exporter-for-eks-on-ec2"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  type        = bool
  description = "Determines if the add-on should be managed via GitOps."
  default     = false
}

variable "service_receivers" {
  type = string
  description = "receiver for adot-ci setup"
  default = "[\"awscontainerinsightreceiver\"]"
}

variable "service_exporters" {
    type = string
    description = "exporter for adot-ci setup"
    default = "[\"awsemf\"]"
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = null
}

#variable "namespace" {
#  description = "adot deployment namespace"
#  type = string
#  default = "adot-exporter-for-eks-on-ec2"
#}
#variable "addon_context" {
#  description = "Input configuration for the addon"
#  type = object({
#    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
#    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
#    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
#    aws_partition_id               = data.aws_partition.current.partition
#    aws_region_name                = data.aws_region.current.nam
#    eks_cluster_id                 = var.eks_cluster_id
#    eks_oidc_issuer_url            = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
#    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
#    tags                           = var.tags
#    irsa_iam_role_path             = var.irsa_iam_role_path
#    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
#  })
#}
