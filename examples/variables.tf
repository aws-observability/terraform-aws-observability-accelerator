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
