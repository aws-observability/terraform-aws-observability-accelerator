variable "java" {
  default = {
    a = ""
    b = ""
  }
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}


variable "enable_amazon_eks_adot" {
  type    = bool
  default = true
}

variable "enable_cert_manager" {
  description = "Allow reusing an existing installation of cert-manager"
  type        = bool
  default     = true
}

variable "enable_opentelemetry_operator" {
  type    = bool
  default = false
}

variable "create_managed_prometheus_workspace" {
  type    = bool
  default = true
}

variable "managed_prometheus_id" {
  description = "AWS Managed Prometheus Workspace ID"
  type        = string
  default     = ""
}

variable "managed_prometheus_endpoint" {
  description = "AWS Managed Prometheus Workspace endpoint"
  type        = string
  default     = ""
}
variable "managed_prometheus_region" {
  description = "AWS Managed Prometheus Workspace Region"
  type        = string
  default     = null
}

variable "enable_java" {
  description = "Deploys a collector for JAVA/JMX based workloads, dashboards and alerting rules"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
