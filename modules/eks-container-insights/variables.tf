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
  type        = string
  description = "receiver for adot-ci setup"
  default     = "awscontainerinsightreceiver"
}

variable "service_exporters" {
  type        = string
  description = "exporter for adot-ci setup"
  default     = "awsemf"
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

variable "adot_otel_helm_chart_verison" {
  description = "ADOT collector helm chart version"
  type        = string
  default     = "0.17.0"
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
