# Monitor Java/JMX applications running on Amazon EKS

!!! warning "v3.0.0 breaking change"
    The `enable_java` and `java_config` variables have been removed in v3.0.0.
    Java/JMX scrape targets are now added via `additional_scrape_jobs`. See the
    [Upgrading to v3.0.0](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/UPGRADING.md)
    guide.

## Setup with v3.0.0

Add your Java/JMX metrics endpoint as an additional scrape job:

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile     = "self-managed-amp"  # or "cloudwatch-otlp"
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  additional_scrape_jobs = [
    {
      job_name        = "java-jmx"
      scrape_interval = "30s"
      static_configs = [
        { targets = ["my-java-app.default.svc.cluster.local:9404"] }
      ]
    }
  ]
}
```

For the `managed-metrics` profile, the same scrape job format applies — it is
passed to the AMP Managed Collector's scrape configuration.

## Custom dashboards

To add a Java/JMX Grafana dashboard, include it in `dashboard_sources`:

```hcl
module "eks_monitoring" {
  # ...
  dashboard_sources = {
    java-jmx = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/java/default.json"
  }
}
```

## Deploy a sample Java application

See the [AWS OTel Collector JMX documentation](https://github.com/aws-observability/aws-otel-collector/blob/main/docs/developers/container-insights-eks-jmx.md)
for a complete walkthrough of deploying a sample Tomcat application with JMX
metrics on EKS.

## Resources

- [OpenTelemetry JMX Metric Gatherer](https://github.com/open-telemetry/opentelemetry-java-contrib/tree/main/jmx-metrics)
- [AWS OTel Collector JMX docs](https://github.com/aws-observability/aws-otel-collector/blob/main/docs/developers/container-insights-eks-jmx.md)
