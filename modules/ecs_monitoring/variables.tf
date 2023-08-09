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
