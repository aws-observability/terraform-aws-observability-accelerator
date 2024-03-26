output "lambda_function_arn" {
  description = "ARN of the Lambda Function"
  value       = aws_lambda_function.observability_accelerator_lambda.arn
}

output "lambda_function_role_arn" {
  description = "ARN of the Lambda Function Execution Role"
  value       = aws_iam_role.lambda_role.arn
}


output "eventbridge_scheduler_arn" {
  description = "ARN of the EventBridge Scheduler"
  value       = aws_scheduler_schedule.eventbridge_scheduler.arn
}

output "eventbridge_scheduler_role_arn" {
  description = "ARN of the EventBridge Scheduler Role"
  value       = aws_iam_role.eventbridge_scheduler_role.arn
}
