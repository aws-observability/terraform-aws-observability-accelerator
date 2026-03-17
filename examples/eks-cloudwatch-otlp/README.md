# EKS CloudWatch OTLP Example

This example deploys the `eks-monitoring` module with the `cloudwatch-otlp` collector profile, sending all telemetry (metrics, traces, logs) to CloudWatch via OTLP endpoints.

## What gets deployed

- Upstream OpenTelemetry Collector via Helm (with SigV4 auth)
- kube-state-metrics and node-exporter Helm charts
- IRSA role with `cloudwatch:PutMetricData`, `CloudWatchLogsFullAccess`, and `AWSXrayWriteOnlyAccess`
- Grafana Prometheus datasource pointing at the CloudWatch PromQL endpoint
- Default infrastructure dashboards in Grafana

## Prerequisites

- An existing EKS cluster with OIDC provider
- An Amazon Managed Grafana workspace with API key
- The CloudWatch OTLP metrics endpoint URL for your region

## Usage

```hcl
terraform init
terraform plan -var="eks_cluster_id=my-cluster" \
  -var="eks_oidc_provider_arn=arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE" \
  -var="cloudwatch_metrics_endpoint=https://monitoring.us-west-2.amazonaws.com/v1/metrics" \
  -var="grafana_endpoint=https://g-abc123.grafana-workspace.us-west-2.amazonaws.com" \
  -var="grafana_api_key=your-api-key"
```
