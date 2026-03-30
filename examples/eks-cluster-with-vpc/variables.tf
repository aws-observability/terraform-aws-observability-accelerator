variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cw-otlp-test"

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]{3,24}$", var.cluster_name))
    error_message = "Cluster name max 25 chars, alphanumeric and hyphens only."
  }
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "managed_node_instance_type" {
  description = "EC2 instance type for managed node group"
  type        = string
  default     = "t3.medium"
}

variable "managed_node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "managed_node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}
