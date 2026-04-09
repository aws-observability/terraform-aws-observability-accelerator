# EKS AMP Self-Managed OTel Collector Example

This example deploys the `eks-monitoring` module with the `self-managed-amp` collector profile, using an in-cluster OTel Collector that remote-writes metrics to AMP, traces to X-Ray, and logs to CloudWatch Logs.

## What gets deployed

- AMP workspace
- Upstream OTel Collector via Helm with SigV4 auth
- kube-state-metrics and node-exporter Helm charts
- IRSA role with Prometheus remote write, X-Ray, and CloudWatch Logs policies
- Prometheus recording and alerting rules
- Default infrastructure dashboards in Grafana

## Prerequisites

- An existing EKS cluster with OIDC provider
- An Amazon Managed Grafana workspace with API key
