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

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "aws_cloudwatch_metrics_chart_verison" {
  description = "AWS CloudWatch Observability Metrics helm chart version"
  type        = string
  default     = "0.0.7"
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
