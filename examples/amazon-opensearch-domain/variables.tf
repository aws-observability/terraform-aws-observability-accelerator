variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "EKS cluster VPC Id"
  type        = string
}

# variable "private_subnet_id" {
#   description = "One of the EKS cluster private subnets"
#   type        = string
# }

# variable "public_subnet_id" {
#   description = "One of the EKS cluster public subnets"
#   type        = string
# }

variable "master_user_name" {
  description = "OpenSearch domain user name"
  type        = string
  default     = ""
}
variable "master_user_password" {
  description = "OpenSearch domain password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "reverse_proxy_client_ip" {
  description = "CIDR block to grant access for OpenSearch reverse proxy"
  type        = string
  default     = "0.0.0.0/0"
}

variable "availability_zone" {
  description = "AZ where the example domain and its proxy instance will be created"
  type        = string
  default     = ""
}
