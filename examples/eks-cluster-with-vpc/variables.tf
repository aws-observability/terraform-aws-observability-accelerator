variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "managed_node_instance_type" {
  description = "Instance type for the cluster managed node groups"
  type        = string
  default     = "t3.xlarge"
}
