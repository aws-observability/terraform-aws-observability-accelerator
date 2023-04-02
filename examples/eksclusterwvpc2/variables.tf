variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
}
