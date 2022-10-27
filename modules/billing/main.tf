resource "aws_cloudwatch_metric_alarm" "amp_billing_anomaly_detection" {
  alarm_name                = "amp_billing_anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  threshold_metric_id       = "e1"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Expected AMP Charges"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Estimated Charges"
      namespace   = "AWS/Billing"
      period      = "21600"
      stat        = "Maximum"
      unit        = "Count"

      dimensions = {
        ServiceName = "Prometheus"
        Currencty   = "USD"
      }
    }
  }
}
