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
variable "managed_prometheus_workspace_id" {
  type    = string
  default = ""
}
variable "managed_prometheus_endpoint" {
  type    = string
  default = ""
}
variable "managed_prometheus_region" {
  type    = string
  default = ""
}


variable "managed_grafana_workspace_id" {
  type    = string
  default = ""
}

