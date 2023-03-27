# Viewing Logs

By default, we deploy a FluentBit daemon set in the cluster to collect worker
logs for all namespaces. Logs collection can be disabled with
`enable_logs = false`. Logs are collected to Amazon CloudWatch Logs, which
enables you to centralize the logs from all of your systems, applications,
and AWS services that you use, in a single, highly scalable service.

Further configuration options are available in the [module documentation](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring#inputs).
This guide shows how you can leverage CloudWatch Logs in Amazon Managed Grafana
for your cluster and application logs.

## Using CloudWatch Logs as data source in Grafana

Follow [the documentation](https://docs.aws.amazon.com/grafana/latest/userguide/using-amazon-cloudwatch-in-AMG.html)
to enable Amazon CloudWatch as a data source. Make sure to provide permissions.

!!! tip
    If you created your workspace with our [provided example](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/managed-grafana/),
    Amazon CloudWatch data source has already been setup for you.

All logs are delivered in the following CloudWatch Log groups naming pattern:
`/aws/eks/observability-accelerator/{cluster-name}/{namespace}`. Log streams
follow `{container-name}.{pod-name}`. In Grafana, querying and analyzing logs
is done with [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)

### Example - ADOT collector logs

Select one or many log groups and run the following query. The example below,
queries AWS Distro for OpenTelemetry (ADOT) logs

```console
fields @timestamp, log
| order @timestamp desc
| limit 100
```



[CloudWatch Logs syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
provide powerful functions to extract data from your logs. The `stats()`
function allows you to calculate aggregate statistics with log field values.
This is useful to have visualization on non-metric data from your applications.

In the example below, we use the following query to graph the number of metrics
collected by the ADOT collector

```console
fields @timestamp, log
| parse log /"#metrics": (?<metrics_count>\d+)}/
| stats avg(metrics_count) by bin(5m)
| limit 100
```

!!! tip
    You can add logs in your dashboards with logs panel types or time series
    depending on your query results type.


!!! warning
    Querying CloudWatch logs will incur costs per GB scanned. Use small time
    windows and limits in your queries. Checkout the CloudWatch
    [pricing page](https://aws.amazon.com/cloudwatch/pricing/) for more infos.
