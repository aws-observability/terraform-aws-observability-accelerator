variable "aws_ecs_cluster_name" {
  description = "Name of your ECS cluster"
  type        = string
}

variable "taskRoleArn" {
  description = "ARN of the IAM Task Role"
  type        = string
}

variable "executionRoleArn" {
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

variable "create_managed_prometheus_ws" {
  description = "Creates a Workspace for Amazon Managed Prometheus"
  type        = bool
  default     = true
}