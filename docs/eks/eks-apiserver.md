# Monitoring EKS API server

AWS Distro of OpenTelemetry enables EKS API server monitoring by default and provides three Grafana dashboards:

## Kube-apiserver (basic)

The basic dashboard shows metrics recommended in [EKS Best Practices Guides - Monitor Control Plane Metrics](https://aws.github.io/aws-eks-best-practices/reliability/docs/controlplane/#monitor-control-plane-metrics) and provides request rate and latency for API server, latency for ETCD server and overall workqueue sercice time and latency. It allows a drill-down per API server.

![image](https://github.com/youwalther65/terraform-aws-observability-accelerator/assets/29410195/9dcf2583-6630-4d3c-911d-8ca48ae2d26f)

## Kube-apiserver (advanced)

The advanced dashboard is derived from kube-prometheus-stack "Kubernetes / API server" dashboard and provides a detailed metrics drill-down for example per READ and WRITE operations per  component (like deployments, configmaps etc.).

![image](https://github.com/youwalther65/terraform-aws-observability-accelerator/assets/29410195/e76a6357-461f-416d-8bf0-5b7777848bea)

## Kube-apiserver (troubleshooting)

This dashboards can be used to troubleshoot API server problems like latency, errors etc.

A detailed description for usage and background information regarding the dashboard can be found in AWS Containers blog post [Troubleshooting Amazon EKS API servers with Prometheus](https://aws.amazon.com/blogs/containers/troubleshooting-amazon-eks-api-servers-with-prometheus/).

![image](https://github.com/youwalther65/terraform-aws-observability-accelerator/assets/29410195/921d3453-dcda-4d8a-8223-7c02f1f08ee2)
