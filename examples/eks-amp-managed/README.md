# EKS AMP Managed Collector Example

This example deploys the `eks-monitoring` module with the `managed-metrics` collector profile, using the AWS-managed Prometheus scraper for agentless metrics collection.

## What gets deployed

- AMP workspace with managed Prometheus scraper
- kube-state-metrics and node-exporter Helm charts
- Prometheus recording and alerting rules
- Default infrastructure dashboards in Grafana

## Prerequisites

- An existing EKS cluster with OIDC provider
- At least 2 subnets in 2 distinct Availability Zones
- Security group(s) allowing scraper access to the EKS cluster
- An Amazon Managed Grafana workspace with API key
