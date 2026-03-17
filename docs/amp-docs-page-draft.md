# Draft: AMP docs page update for v3.0.0

> This is a draft replacement for the AMP docs page at
> https://docs.aws.amazon.com/prometheus/latest/userguide/obs_accelerator.html
>
> Hold merge until the doc team publishes the updated page.
> The eks-amp-otel-getting-started example has been rewritten for v3.

---

## Set up Amazon Managed Service for Prometheus with AWS Observability Accelerator

AWS provides observability tools, including monitoring, logging, alerting, and
dashboards, for your Amazon Elastic Kubernetes Service (Amazon EKS) projects.
This includes Amazon Managed Service for Prometheus, Amazon Managed Grafana,
OpenTelemetry Collector, and other tools. To help you use these tools together,
AWS provides Terraform modules that configure observability with these services,
called the AWS Observability Accelerator.

AWS Observability Accelerator provides examples for monitoring infrastructure,
Java/JMX, NGINX, Istio, and other workloads. This section gives an example of
monitoring infrastructure within your Amazon EKS cluster using the
`self-managed-amp` collector profile, which deploys an OpenTelemetry Collector
to scrape Prometheus metrics and remote-write to Amazon Managed Prometheus.

### Prerequisites

- An existing Amazon EKS cluster
- AWS CLI
- kubectl
- Terraform >= 1.5.0

The AWS provider must be configured with an IAM role that has access to create
and manage Amazon Managed Service for Prometheus, Amazon Managed Grafana, and
IAM within your AWS account.

### Using the infrastructure monitoring example

#### 1. Clone the repository

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
```

#### 2. Initialize Terraform

```bash
cd examples/eks-amp-otel-getting-started
terraform init
```

#### 3. Create terraform.tfvars

```hcl
# (mandatory) AWS Region where your resources will be located
aws_region = "eu-west-1"

# (mandatory) EKS Cluster name
eks_cluster_id = "my-eks-cluster"

# (mandatory) ARN of the EKS OIDC provider for IRSA role creation
eks_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE"
```

#### 4. Amazon Managed Grafana workspace

Create an Amazon Managed Grafana workspace if you don't already have one.

v3.0.0 uses the Grafana Terraform provider to provision dashboards directly.
Set up the Grafana workspace ID and API key:

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
export TF_VAR_grafana_api_key=$(aws grafana create-workspace-api-key \
  --key-name "observability-accelerator-$(date +%s)" \
  --key-role ADMIN \
  --seconds-to-live 7200 \
  --workspace-id $TF_VAR_managed_grafana_workspace_id \
  --query key --output text)
```

#### 5. (Optional) Existing Amazon Managed Prometheus workspace

To use an existing AMP workspace, add the ID to terraform.tfvars:

```hcl
# (optional) Leave empty for a new workspace to be created
managed_prometheus_workspace_id = "ws-xxx"
```

#### 6. Deploy

```bash
terraform apply -var-file=terraform.tfvars
```

### Resources created

This creates the following resources in your AWS account:

- A new Amazon Managed Service for Prometheus workspace (unless you opted to
  use an existing workspace)
- Prometheus recording and alerting rules in your AMP workspace
- Grafana dashboards provisioned via the Grafana Terraform provider in your
  Amazon Managed Grafana workspace (cluster, kubelet, namespace workloads,
  node-exporter, nodes, workloads)
- An OpenTelemetry Collector deployed via Helm in your EKS cluster, configured
  to scrape Prometheus metrics and remote-write to AMP
- kube-state-metrics and node-exporter deployed via Helm for infrastructure
  metrics
- An IRSA role for the OTel Collector service account
- Traces pipeline to AWS X-Ray (enabled by default)
- Logs pipeline to CloudWatch Logs (enabled by default)

### Alternative: Managed metrics (agentless)

For the simplest setup with no in-cluster collector, use the `managed-metrics`
profile with the `examples/eks-amp-managed/` example. This uses the AMP
Managed Collector (agentless scraper) instead of deploying an OTel Collector.

```hcl
collector_profile          = "managed-metrics"
scraper_subnet_ids         = ["subnet-xxx", "subnet-yyy"]  # >= 2 AZs
scraper_security_group_ids = ["sg-xxx"]
```

### Viewing dashboards

Open your Amazon Managed Grafana workspace. The infrastructure dashboards are
provisioned automatically by Terraform. Navigate to the dashboards panel to
view cluster, kubelet, namespace workloads, node-exporter, nodes, and workloads
dashboards.
