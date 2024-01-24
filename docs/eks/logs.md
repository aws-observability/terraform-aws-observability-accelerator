# Viewing Logs

By default, we deploy a FluentBit daemon set in the cluster to collect worker
logs for all namespaces. Logs collection can be disabled with
`enable_logs = false`. Logs are collected and exported to Amazon CloudWatch Logs,
which enables you to centralize the logs from all of your systems, applications,
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
`/aws/eks/observability-accelerator/{cluster-name}/workloads`. Log streams
follow the naming pattern `{node-name}`. In Grafana, querying and analyzing logs
is done with [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)

### Example - ADOT collector logs

Select workloads log group for the cluster and run the following query. The example below,
queries container logs from `kube-system` namespace.

```console
fields @timestamp, @message, @logStream, @log, resource.k8s.namespace.name
| filter resource.k8s.namespace.name = "kube-system"
| sort @timestamp desc
| limit 100
```

<img width="1987" alt="Screenshot 2023-03-27 at 19 08 35" src="https://user-images.githubusercontent.com/10175027/228037030-95005f47-ff46-4f7a-af74-d31809c52fcd.png">


### Example - Using time series visualizations

[CloudWatch Logs syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
provide powerful functions to extract data from your logs. The `stats()`
function allows you to calculate aggregate statistics with log field values.
This is useful to have visualization on non-metric data from your applications.

In the example below, we use the following query to graph the number of metrics
collected by the ADOT collector

```console
fields @timestamp, attributes.log
| filter resource.k8s.namespace.name = "adot-collector-kubeprometheus"
| parse attributes.log  /\"metrics\": (?<metrics_count>\d+?)(,|\})/
| stats avg(metrics_count) by bin(5m)
| limit 100
```

!!! tip
    You can add logs in your dashboards with logs panel types or time series
    depending on your query results type.

<img width="2056" alt="image" src="https://user-images.githubusercontent.com/10175027/228037186-12691590-0bfe-465b-a83b-5c4f583ebf96.png">

!!! warning
    Querying CloudWatch logs will incur costs per GB scanned. Use small time
    windows and limits in your queries. Checkout the CloudWatch
    [pricing page](https://aws.amazon.com/cloudwatch/pricing/) for more infos.
