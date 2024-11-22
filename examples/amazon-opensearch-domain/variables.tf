variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "EKS cluster VPC Id"
  type        = string
}

variable "master_user_name" {
  description = "OpenSearch domain user name"
  type        = string
  default     = "observability-accelerator"
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

variable "expose_proxy" {
  description = "Whether or not to expose EC2 proxy instance for Amazon Opensearch dashboards to the Internet"
  type        = bool
  default     = false
}
