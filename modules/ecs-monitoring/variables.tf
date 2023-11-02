variable "aws_ecs_cluster_name" {
  description = "Name of your ECS cluster"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM Task Role"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM Execution Role"
  type        = string
}

variable "ecs_adot_cpu" {
  description = "CPU to be allocated for the ADOT ECS TASK"
  type        = string
  default     = "256"
}

variable "ecs_adot_mem" {
  description = "Memory to be allocated for the ADOT ECS TASK"
  type        = string
  default     = "512"
}

variable "create_managed_grafana_ws" {
  description = "Creates a Workspace for Amazon Managed Grafana"
  type        = bool
  default     = true
}

variable "create_managed_prometheus_ws" {
  description = "Creates a Workspace for Amazon Managed Prometheus"
  type        = bool
  default     = true
}

variable "refresh_interval" {
  description = "Refresh interval for ecs_observer"
  type        = string
  default     = "60s"
}

variable "ecs_metrics_collection_interval" {
  description = "Collection interval for ecs metrics"
  type        = string
  default     = "15s"
}

variable "otlp_grpc_endpoint" {
  description = "otlpGrpcEndpoint"
  type        = string
  default     = "0.0.0.0:4317"
}


variable "otlp_http_endpoint" {
  description = "otlpHttpEndpoint"
  type        = string
  default     = "0.0.0.0:4318"
}

variable "container_name" {
  description = "Container Name for Adot"
  type        = string
  default     = "adot_new"
}

variable "otel_image_ver" {
  description = "Otel Docker Image version"
  type        = string
  default     = "v0.31.0"
}
