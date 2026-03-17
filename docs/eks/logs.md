# Viewing Logs

The `eks-monitoring` module supports logs collection via the OpenTelemetry
Collector for profiles that deploy one.

## How logs work in v3

| Profile | Logs support | Destination |
|---------|-------------|-------------|
| `self-managed-amp` | Yes (toggle with `enable_logs`) | CloudWatch Logs via OTLP |
| `cloudwatch-otlp` | Yes (always enabled) | CloudWatch Logs via OTLP |
| `managed-metrics` | No (metrics only) | — |

Logs collection can be disabled in the `self-managed-amp` profile with
`enable_logs = false`.

## Sending application logs

Applications send logs to the OTel Collector via OTLP. Configure your
application's OTLP exporter:

```yaml
env:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector.otel-collector.svc.cluster.local:4317"
```

For the `cloudwatch-otlp` profile, logs are exported with the `x-aws-log-group`
and `x-aws-log-stream` headers set from `cloudwatch_log_group` and
`cloudwatch_log_stream` variables.

## Using CloudWatch Logs as data source in Grafana

Follow [the documentation](https://docs.aws.amazon.com/grafana/latest/userguide/using-amazon-cloudwatch-in-AMG.html)
to enable Amazon CloudWatch as a data source in your Grafana workspace.

!!! tip
    If you created your workspace with our [provided example](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/managed-grafana/),
    Amazon CloudWatch data source has already been set up for you.

In Grafana, querying and analyzing logs is done with
[CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html).

### Example query

Select your log group and run:

```
fields @timestamp, log
| order @timestamp desc
| limit 100
```

### Time series from logs

Use the `stats()` function to create visualizations from log data:

```
fields @timestamp, log
| parse log /"#metrics": (?<metrics_count>\d+)}/
| stats avg(metrics_count) by bin(5m)
| limit 100
```

!!! tip
    You can add logs in your dashboards with logs panel types or time series
    depending on your query results type.

!!! warning
    Querying CloudWatch logs incurs costs per GB scanned. Use small time
    windows and limits in your queries. See the CloudWatch
    [pricing page](https://aws.amazon.com/cloudwatch/pricing/) for details.
