output "adot_logs_collector_config" {
  description = "ADOT Container Logs Collector configuration"
  value = jsondecode(length(resource.aws_cloudwatch_log_group.adot_log_group) > 0 ? jsonencode({
    resources = {
      limits = {
        cpu    = "1000m"
        memory = "750Mi"
      }

      requests = {
        cpu    = "300m"
        memory = "512Mi"
      }
    }

    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" = module.adot_logs_iam_role[0].iam_role_arn
      }
    }

    exporters = {
      awscloudwatchlogs = {
        log_group_name  = "/aws/eks/observability-accelerator/$CLUSTER_NAME/workloads"
        log_stream_name = "$NODE_NAME"
      }
    }

    pipelines = {
      logs = {
        cloudwatchLogs = {
          enabled = true
        }
      }
    }
  }) : "{}")
}
