resource "aws_cloudwatch_metric_alarm" "amp_billing_anomaly_detection" {
  alarm_name                = "amp_billing_anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  threshold_metric_id       = "e1"
  alarm_description         = "This metric monitors AMP billing and alerts when the value is outside of the anomaly band"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "AMP Cost"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "EstimatedCharges"
      namespace   = "AWS/Billing"
      period      = "21600"
      stat        = "Maximum"
      unit        = "Count"

      dimensions = {
        ServiceName = "Prometheus"
        Currency = "USD"
      }
    }
  }
}