# AGENT.md — AI Agent Instructions for AWS Observability Accelerator

You are helping a user deploy EKS observability using this Terraform repository.
Your job is to guide them through deployment conversationally — gather the info
you need, pick the right example, run Terraform, and hand them working dashboard URLs.

## Repository Structure

```
modules/eks-monitoring/          # Core module — all profiles
examples/
  eks-cloudwatch-otlp/           # CloudWatch OTLP (recommended, self-contained)
  eks-amp-managed/               # AMP with managed collector (agentless)
  eks-amp-otel/                  # AMP with self-managed OTel Collector
  eks-cluster-with-vpc/          # Helper: create an EKS cluster
  managed-grafana-workspace/     # Helper: create a Grafana workspace
dashboards/
  original/                      # Standard Prometheus/AMP dashboards
  zeus/                          # Zeus (CloudWatch OTLP) dashboards
scripts/
  zeus-dashboard-transform.py    # Converts original → Zeus dashboards
```

## Collector Profiles

The `eks-monitoring` module supports three profiles via `collector_profile`:

| Profile | Backend | Collector | Best for |
|---------|---------|-----------|----------|
| `cloudwatch-otlp` | CloudWatch (Zeus) | OTel Collector (Helm) | New deployments, no AMP needed |
| `managed-metrics` | AMP | AWS Managed Collector (agentless) | Zero collector management |
| `self-managed-amp` | AMP | OTel Collector (Helm) | Full control over collector config |

**Default recommendation: `cloudwatch-otlp`** — simplest path, no AMP workspace needed,
metrics queryable via CloudWatch PromQL endpoint in Grafana.

## Deployment Workflow

### Step 1: Gather Information

Ask the user for (or look up via AWS CLI):

1. **AWS Region** — where to deploy (default: `us-west-2`)
2. **EKS Cluster Name** — must already exist with OIDC provider
   - Check: `aws eks list-clusters --region <region>`
   - Verify OIDC: `aws eks describe-cluster --name <name> --query "cluster.identity.oidc"`
3. **Profile choice** — recommend `cloudwatch-otlp` unless they specifically need AMP
4. **Existing Grafana workspace?** — the `eks-cloudwatch-otlp` example creates one automatically

If the user doesn't have an EKS cluster, point them to `examples/eks-cluster-with-vpc/`.

### Step 2: Deploy (CloudWatch OTLP — recommended)

```bash
cd examples/eks-cloudwatch-otlp

# Option A: One-command install (recommended)
./install.sh -var="eks_cluster_id=<CLUSTER>" -var="aws_region=<REGION>"

# Option B: Manual two-step
terraform init
terraform apply -var="eks_cluster_id=<CLUSTER>" -var="aws_region=<REGION>"

# Then provision dashboards:
terraform apply \
  -var="eks_cluster_id=<CLUSTER>" \
  -var="aws_region=<REGION>" \
  -var="grafana_endpoint=$(terraform output -raw grafana_workspace_endpoint)" \
  -var="grafana_api_key=$(terraform output -raw grafana_api_key)"
```

### Step 3: Hand Over Results

After successful apply, give the user:

1. **Grafana URL**: `terraform output grafana_workspace_endpoint`
2. **Dashboards available**:
   - Cluster overview
   - Kubelet metrics
   - Node metrics
   - Node Exporter metrics
   - Namespace Workloads
   - Workloads
3. **Note**: User must log in via AWS IAM Identity Center (SSO) to access Grafana

### Step 4: Verify Data Flow

```bash
# Check OTel Collector pods are running
kubectl get pods -n otel-collector

# Check kube-state-metrics
kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-state-metrics

# Check node-exporter
kubectl get pods -n prometheus-node-exporter
```

If metrics aren't showing in dashboards after 5 minutes, check collector logs:
```bash
kubectl logs -n otel-collector -l app.kubernetes.io/name=opentelemetry-collector --tail=50
```

## Deploy with AMP (managed-metrics profile)

If the user wants AMP instead:

```bash
cd examples/eks-amp-managed
terraform init
terraform apply \
  -var="eks_cluster_id=<CLUSTER>" \
  -var="aws_region=<REGION>"
```

This creates an AMP workspace + managed collector (agentless). Requires:
- At least 2 subnets in 2 AZs for the scraper
- Security groups allowing scraper → EKS API access

## Configuration Reference

### Key Variables (eks-monitoring module)

| Variable | Default | Description |
|----------|---------|-------------|
| `collector_profile` | (required) | `cloudwatch-otlp`, `managed-metrics`, or `self-managed-amp` |
| `eks_cluster_id` | (required) | EKS cluster name |
| `cloudwatch_metrics_endpoint` | regional default | Override CloudWatch OTLP endpoint |
| `create_amp_workspace` | `true` | Create new AMP workspace (AMP profiles) |
| `enable_dashboards` | `true` | Provision Grafana dashboards |
| `otel_collector_chart_version` | `0.78.0` | OTel Collector Helm chart version |
| `enable_tracing` | `true` | Enable X-Ray traces pipeline (self-managed-amp) |
| `enable_logs` | `true` | Enable CloudWatch Logs pipeline (self-managed-amp) |

### Key Outputs

| Output | Description |
|--------|-------------|
| `grafana_workspace_endpoint` | Grafana URL (eks-cloudwatch-otlp example) |
| `collector_irsa_arn` | OTel Collector IAM role ARN |
| `cloudwatch_promql_datasource_config` | Grafana datasource connection details |
| `managed_prometheus_workspace_endpoint` | AMP endpoint (AMP profiles) |

## Cleanup

```bash
terraform destroy -var="eks_cluster_id=<CLUSTER>" -var="aws_region=<REGION>"
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No metrics in Grafana | Collector not running | `kubectl get pods -n otel-collector` |
| `Attribute string value cannot be blank` in collector logs | Blank resource attributes | Already handled by `transform/zeus_compat` processor |
| `Failed to parse query: unexpected character '@'` | Grafana v10 with @ label syntax | Use Zeus dashboards from `dashboards/zeus/` (standard labels) |
| 504 timeout on Grafana datasource | SigV4 auth misconfigured | Check IRSA role has `monitoring` service permissions |
| Dashboards show "No data" | Metrics not yet ingested | Wait 5 min, check collector logs |
