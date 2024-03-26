output "ssmparameter_name" {
  description = "Name of the SSM Parameter"
  value       = aws_ssm_parameter.secret.name
}

output "ssmparameter_arn" {
  description = "Name of the SSM Parameter"
  value       = aws_ssm_parameter.secret.arn
}

output "kms_key_arn_ssm" {
  description = "Name of the SSM Parameter"
  value       = aws_kms_key.secrets.arn
}
