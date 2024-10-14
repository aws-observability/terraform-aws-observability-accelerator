variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "EKS cluster VPC Id"
  type        = string
}

variable "private_subnet_id" {
  description = "One of the EKS cluster private subnets"
  type        = string
}

variable "public_subnet_id" {
  description = "One of the EKS cluster public subnets"
  type        = string
}

variable "master_user_name" {
  description = "OpenSearch domain user name"
  type        = string
}
variable "master_user_password" {
  description = "OpenSearch domain password"
  type        = string
  sensitive   = true
}

variable "reverse_proxy_client_ip" {
  description = "CIDR block to grant access for OpenSearch reverse proxy"
  type        = string
  default     = "127.0.0.1/32"
}
