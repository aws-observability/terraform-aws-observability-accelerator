# Monitoring Amazon EKS API server

AWS Distro for OpenTelemetry (ADOT) enables Amazon EKS API server monitoring by default and provides three Grafana dashboards:

## Kube-apiserver (basic)

The basic dashboard shows metrics recommended in [EKS Best Practices Guides - Monitor Control Plane Metrics](https://aws.github.io/aws-eks-best-practices/reliability/docs/controlplane/#monitor-control-plane-metrics) and provides request rate and latency for API server, latency for ETCD server and overall workqueue service time and latency. It allows a drill-down per API server.

![API server basic dashboard](https://github.com/aws-observability/terraform-aws-observability-accelerator/assets/10175027/d4ba74c4-7530-4037-b373-fa68986cabfc)


## Kube-apiserver (advanced)

The advanced dashboard is derived from kube-prometheus-stack `Kubernetes / API server` dashboard and provides a detailed metrics drill-down for example per READ and WRITE operations per component (like deployments, configmaps etc.).

![API server advanced dashboard](https://github.com/aws-observability/terraform-aws-observability-accelerator/assets/10175027/8d614a6d-38c5-47bc-acfc-6cea4bc1f070)


## Kube-apiserver (troubleshooting)

This dashboard can be used to troubleshoot API server problems like latency, errors etc.

A detailed description for usage and background information regarding the dashboard can be found in AWS Containers blog post [Troubleshooting Amazon EKS API servers with Prometheus](https://aws.amazon.com/blogs/containers/troubleshooting-amazon-eks-api-servers-with-prometheus/).

![API server troubleshooting dashboard](https://github.com/aws-observability/terraform-aws-observability-accelerator/assets/10175027/687b5fac-8ae4-4a49-924c-6b3d708b9569)
