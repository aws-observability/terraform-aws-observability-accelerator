# Monitoring EKS API server

AWS Distro of OpenTelemetry enables EKS API server monitoring by default and provides three Grafana dashboards:

## Kube-apiserver (basic)

The basic dashboard shows metrics recommended in [EKS Best Practices Guides - Monitor Control Plane Metrics](https://aws.github.io/aws-eks-best-practices/reliability/docs/controlplane/#monitor-control-plane-metrics) and provides request rate and latency for API server, latency for ETCD server and overall workqueue sercice time and latency. It allows a drill-down per API server

## Kube-apiserver (advanced)

The advanced dashboard is derived from kube-prometheus-stack and provides a detailed metrics drill-down for example per READ and WRITE operations per  component (like deployments, configmaps etc.).

## Kube-apiserver (troubleshooting)

This dashboards can be used to troubleshoot API server probblems like latency, errors etc. A detailed description for usage and background information regarding the dashboard can be found in AWS Containers blog post [Troubleshooting Amazon EKS API servers with Prometheus](https://aws.amazon.com/blogs/containers/troubleshooting-amazon-eks-api-servers-with-prometheus/).


