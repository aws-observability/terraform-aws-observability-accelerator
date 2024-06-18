variable "lambda_function_name" {
  description = "Name of the Lambda Function"
  type        = string
  default     = "observability-accelerator-lambda"
}

variable "lambda_execution_role_name" {
  description = "Name of the Lambda Execution Role"
  type        = string
  default     = "observability-accelerator-lambdaRole"
}

variable "lambda_execution_role_policy_name" {
  description = "Name of the Lambda Execution Role Policy"
  type        = string
  default     = "observability-accelerator-lambda-Policy"
}

variable "eventbridge_scheduler_name" {
  description = "Name of the EventBridge Scheduler"
  type        = string
  default     = "observability-accelerator-EBridge"
}

variable "eventbridge_scheduler_role_name" {
  description = "ExecutionRole for EventBridge Scheduler"
  type        = string
  default     = "observability-accelerator-EBridgeRole"
}

variable "eventbridge_scheduler_role_policy_name" {
  description = "ExecutionRole for EventBridge Scheduler"
  type        = string
  default     = "observability-accelerator-EBridge-Policy"
}

variable "ssmparameter_arn" {
  description = "ARN of the SSM Parameter to be used in the Lambda execution role policy"
  type        = string
}

variable "ssmparameter_name" {
  description = "Name of the SSM Parameter to store the API Key for Grafana"
  type        = string
}

variable "kms_key_arn_ssm" {
  description = "ARN of the CMK KMS Key used to encrypt the SSM Parameter value"
  type        = string
}

variable "grafana_api_key_interval" {
  description = "Number of seconds for secondsToLive value while creating API Key"
  type        = number
  default     = 5400
}

variable "managed_grafana_workspace_id" {
  description = "Amazon Managed Grafana Workspace ID"
  type        = string
}

variable "eventbridge_scheduler_schedule_expression" {
  description = "Schedule Expression for EventBridge Scheduler in Grafana API Key Rotation"
  type        = string
  default     = "rate(60 minutes)"
}

variable "lambda_runtime_grafana_key_rotation" {
  description = "Python Runtime Identifier for the Lambda Function"
  type        = string
  default     = "python3.12"
}
