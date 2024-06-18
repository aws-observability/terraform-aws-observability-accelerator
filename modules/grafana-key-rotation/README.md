# API Key Rotation for Amazon Managed Grafana Workspace

- This module automates the rotation of Amazon Managed Grafana Workspace API Keys.
- When created, it generates an API Key for Amazon Managed Grafana Workspace on a schedule and updates the SSM parameter value to use this new key; this would then be consumed by the External Secrets Operator in `eks-monitoring` module deployed to EKS Cluster which retrieves and Syncs the Grafana API keys from AWS SSM Parameter Store.
- This module/feature is enabled by default and can be disabled setting the value of `enable_grafana_key_rotation` variable to `false` in the `variables.tf` file of `existing-cluster-with-base-and-infra` example.

## Resources created through the module
The following AWS resources are created through this module to implement API key rotation :
- Lambda function
    - To create a new Grafana API Key
    - Update the SSM Parameter Value
    - Delete older API key.
- Lambda Execution IAM Role
    - To provide permissions related to grafana, SSM and CloudWatch logs to Lambda function.
    - The permissions of the role are restricted to the specific Grafana workspace and SSM parameter that are in scope of this solution.
- EventBridge Scheduler
    - To invoke the Lambda function on a cron-based schedule.
- EventBridge Scheduler IAM Role
    - To provide permissions to the EventBridge Schedule to invoke the Lambda function.
    - The permissions of the role are restricted to the specific Lambda function created in this solution.


## Configuration Options

### Through the `grafana-key-rotation` module
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda_function_name | Name of the Lambda function that creates the API Key and updates the SSM Parameter | `string` | `observability-accelerator-lambda` | No |
| lambda_execution_role_name | Name of Lambda Execution IAM Role | `string` | "`observability-accelerator-lambdaRole`" | No |
| lambda_execution_role_policy_name | Name of the Lambda Execution Role Policy | `string` | "`observability-accelerator-lambda-Policy`" | No |
| eventbridge_scheduler_name | Name of the EventBridge Scheduler that triggers the Lambda function | `string` | "`observability-accelerator-EBridge`" | No |
| eventbridge_scheduler_role_name | Name of the IAM role for EventBridge | `string` | "`observability-accelerator-EBridgeRole`" | No |
| eventbridge_scheduler_role_policy_name | Name of the IAM policy for EventBridge Role | `string` | "`observability-accelerator-EBridge-Policy`" | No |
| grafana_api_key_interval | Interval to be used while creating Grafana API Key | `number` | "`5400`" | No |
| eventbridge_scheduler_schedule_expression | Schedule Expression for EventBridge Scheduler in Grafana API Key Rotation | `string` | "`rate(60 minutes)`" | No |
| lambda_runtime_grafana_key_rotation | "Python Runtime Identifier for the Lambda Function" | `string` | "`python3.12`" | No |

### Through the `existing-cluster-with-base-and-infra` example
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_grafana_key_rotation | Enables or disables Grafana API key rotation | `bool` | "`true`" | No |
| grafana_api_key_refresh_interval | Refresh Internal to be used by External Secrets Operator of eks-monitoring module, for Grafana API Key rotation | `string` | "`5m`" | No |
