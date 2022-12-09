#CloudWatch Alerts on AMP Usage
resource "aws_cloudwatch_metric_alarm" "active_series_metrics" {
  for_each                  = local.amp_list
  alarm_name                = "active-series-metrics"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = var.active_series_threshold
  alarm_description         = "This metric monitors AMP active series metrics"
  insufficient_data_actions = []
  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "ResourceCount"
      namespace   = "AWS/Usage"
      period      = "120"
      stat        = "Average"
      unit        = "None"

      dimensions = {
        Type       = "Resource"
        ResourceId = each.key
        Resource   = "ActiveSeries"
        Service    = "Prometheus"
        Class      = "None"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ingestion_rate" {
  for_each                  = local.amp_list
  alarm_name                = "ingestion_rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = var.ingestion_rate_threshold
  alarm_description         = "This metric monitors AMP ingestion rate"
  insufficient_data_actions = []
  metric_query {
    id          = "m1"
    return_data = true

    metric {
      metric_name = "ResourceCount"
      namespace   = "AWS/Usage"
      period      = "120"
      stat        = "Average"
      unit        = "None"

      dimensions = {
        Type       = "Resource"
        ResourceId = each.key
        Resource   = "IngestionRate"
        Service    = "Prometheus"
        Class      = "None"
      }
    }
  }
}
