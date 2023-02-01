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
variable "managed_node_min_size" {
  description = "Minumum number of instances in the node group"
  type        = number
  default     = 2
}
variable "eks_version" {
  type        = string
  description = "EKS Cluster version"
  default     = "1.24"
}
