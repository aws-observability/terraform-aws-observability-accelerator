# Existing Cluster with EKS Infrastructure Monitoring (v3)

This example demonstrates how to use the AWS Observability Accelerator
`eks-monitoring` module with the `self-managed-amp` profile for infrastructure
monitoring on an existing EKS cluster.

It deploys an OpenTelemetry Collector via Helm to scrape Prometheus metrics
(kube-state-metrics, node-exporter, kubelet) and remote-write to Amazon Managed
Prometheus. Grafana dashboards are provisioned via the Grafana Terraform
provider. Traces (X-Ray) and logs (CloudWatch Logs) pipelines are enabled by
default.

## Prerequisites

- An existing Amazon EKS cluster
- An [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/what-is-Amazon-Managed-Service-Grafana.html) workspace
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Usage

```bash
export TF_VAR_eks_cluster_id=my-cluster
export TF_VAR_aws_region=us-west-2
export TF_VAR_managed_grafana_workspace_id=g-xxx
export TF_VAR_grafana_api_key=$(aws grafana create-workspace-api-key \
  --key-name "observability-accelerator-$(date +%s)" \
  --key-role ADMIN \
  --seconds-to-live 7200 \
  --workspace-id $TF_VAR_managed_grafana_workspace_id \
  --query key --output text)

terraform init
terraform apply
```

To use an existing AMP workspace:

```bash
export TF_VAR_managed_prometheus_workspace_id=ws-xxx
```

## Documentation

Full documentation: [https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/)
