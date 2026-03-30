# AGENT.md — AI Agent Instructions for AWS Observability Accelerator

You are helping a user deploy EKS observability using this Terraform repository.
Your job is to guide them through deployment conversationally — gather the info
you need, provision prerequisites, run Terraform, and hand them working dashboard URLs.

## Repository Structure

```
modules/eks-monitoring/          # Core module — all profiles
examples/
  eks-cluster-with-vpc/          # Prereq: create an EKS cluster + VPC
  managed-grafana-workspace/     # Prereq: create a Grafana workspace + API token
  eks-cloudwatch-otlp/           # CloudWatch OTLP via OTel Collector (public-ready)
  eks-amp-managed/               # AMP with managed collector (agentless)
  eks-amp-otel/                  # AMP with self-managed OTel Collector
dashboards/
  original/                      # Standard Prometheus dashboards (AMP + OTel→CW OTLP)
  zeus/                          # Container Insights dashboards (CW Agent, not public yet)
scripts/
  zeus-dashboard-transform.py    # Converts original → zeus dashboards
```

## Collector Profiles

| Profile | Collector | Backend | Example | Status |
|---------|-----------|---------|---------|--------|
| `cloudwatch-otlp` | OTel Collector (Helm) | CloudWatch OTLP endpoint | `eks-cloudwatch-otlp/` | Public-ready (dashboards need work) |
| `managed-metrics` | AMP Managed Scraper (agentless) | AMP | `eks-amp-managed/` | Public-ready |
| `self-managed-amp` | OTel Collector (Helm) | AMP | `eks-amp-otel/` | Public-ready |
| `cloudwatch-container-insights` | CW Agent / EKS add-on | CloudWatch | — | **Parked** — waiting for public chart/add-on GA |

### Profile details

**`cloudwatch-otlp`** (recommended for CloudWatch users)
- Deploys OTel Collector scraping kube-state-metrics, node-exporter, kubelet
- Exports to CloudWatch OTLP metrics endpoint via SigV4 auth
- Endpoint is configurable: defaults to `https://monitoring.<region>.amazonaws.com/v1/metrics`
  but can be overridden via `cloudwatch_metrics_endpoint` for internal/pre-release testing
- Uses `original/` dashboards with a CloudWatch PromQL datasource
- IRSA role needs `cloudwatch:PutMetricData`

**`managed-metrics`** (recommended for AMP users wanting zero management)
- AMP managed scraper — no in-cluster collector to manage
- Requires at least 2 subnets in 2 AZs
- Uses `original/` dashboards with an AMP datasource

**`self-managed-amp`** (full control)
- OTel Collector with AMP remote write, optional X-Ray traces + CW Logs
- IRSA role with AMP, X-Ray, and CW Logs policies
- Uses `original/` dashboards with an AMP datasource

**`cloudwatch-container-insights`** (NOT YET PUBLIC)
- Amazon CloudWatch Observability Helm chart (CW Agent DaemonSet, Fluent Bit,
  kube-state-metrics, node-exporter, cluster scraper)
- Chart `amazon-cloudwatch-observability` is not yet in a public Helm repo
- Will eventually become an EKS add-on (`aws_eks_addon` resource)
- Uses `zeus/` dashboards
- **Do not use for public examples** — dependencies are pending

---

## Deployment Playbook

Follow these steps in order. Each step checks whether the resource exists
before creating it.

### Step 0: Gather Information

Ask the user for:

1. **AWS Region** (default: `us-east-1`)
2. **Profile choice** — recommend `cloudwatch-otlp` for CloudWatch, `managed-metrics` for AMP

Then check what already exists:

```bash
# Existing EKS clusters
aws eks list-clusters --region <REGION>

# Existing Grafana workspaces
aws grafana list-workspaces --region <REGION> \
  --query 'workspaces[*].{name:name,id:id,endpoint:endpoint,status:status}'
```

Ask the user:
- Do you have an EKS cluster to use, or should I create one?
- Do you have a Grafana workspace, or should I create one? (optional — dashboards can be skipped)

### Step 1: EKS Cluster (if needed)

If the user has no cluster, provision one:

```bash
cd examples/eks-cluster-with-vpc
terraform init
terraform apply -var="cluster_name=<NAME>" -var="aws_region=<REGION>"
```

This creates:
- VPC with private/public subnets and NAT gateway
- EKS cluster with `t3.medium` managed node group
- Node IAM roles with `CloudWatchAgentServerPolicy` + `AmazonEC2ContainerRegistryReadOnly`

After completion:

```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_id) --region <REGION>
```

### Step 2: Grafana Workspace (if needed, optional)

If the user wants dashboards and has no workspace:

```bash
cd examples/managed-grafana-workspace
terraform init
terraform apply -var="aws_region=<REGION>"
```

**Requires**: AWS IAM Identity Center (SSO) configured in the account.

Record the outputs:
```bash
GRAFANA_ENDPOINT=$(terraform output -raw grafana_workspace_endpoint)
GRAFANA_API_KEY=$(terraform output -raw grafana_api_key)
```

If the user has an existing workspace but no API token:

```bash
SA_ID=$(aws grafana create-workspace-service-account \
  --workspace-id <ID> --name terraform --grafana-role ADMIN \
  --region <REGION> --query 'id' --output text)

aws grafana create-workspace-service-account-token \
  --workspace-id <ID> --service-account-id $SA_ID \
  --name terraform-token --seconds-to-live 2592000 \
  --region <REGION>
```

### Step 3: Deploy Monitoring

Write `terraform.tfvars` in the chosen example directory:

```hcl
eks_cluster_id = "<CLUSTER_NAME>"
aws_region     = "<REGION>"
```

#### CloudWatch OTLP

```bash
cd examples/eks-cloudwatch-otlp

# Without dashboards
./install.sh

# With dashboards
./install.sh \
  -var="grafana_endpoint=<ENDPOINT>" \
  -var="grafana_api_key=<KEY>"

# With custom OTLP endpoint (for internal testing)
./install.sh \
  -var="cloudwatch_metrics_endpoint=https://custom-endpoint.example.com/v1/metrics"
```

#### AMP Managed Scraper

```bash
cd examples/eks-amp-managed
terraform init
terraform apply
```

#### AMP Self-Managed OTel

```bash
cd examples/eks-amp-otel
terraform init
terraform apply \
  -var="grafana_endpoint=<ENDPOINT>" \
  -var="grafana_api_key=<KEY>"
```

### Step 4: Verify

```bash
# For cloudwatch-otlp or self-managed-amp (OTel Collector)
kubectl get pods -n otel-collector

# For managed-metrics (no in-cluster pods — check AMP scraper)
aws amp list-scrapers --region <REGION>

# Check kube-state-metrics and node-exporter
kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-state-metrics
kubectl get pods -n prometheus-node-exporter
```

### Step 5: Hand Over Results

Give the user:

1. **Grafana URL** (if provisioned) — log in via AWS IAM Identity Center (SSO)
2. **Dashboards**: Cluster, Kubelet, Nodes, Node Exporter, Namespace Workloads, Workloads
3. **Collector namespace**: `otel-collector` (OTel profiles) or check AMP scraper (managed)

---

## Cleanup

Destroy in reverse order:

```bash
# Monitoring
cd examples/eks-cloudwatch-otlp  # or eks-amp-managed, eks-amp-otel
./destroy.sh  # or terraform destroy

# Grafana (if created)
cd ../managed-grafana-workspace
terraform destroy -var="aws_region=<REGION>"

# Cluster (if created)
cd ../eks-cluster-with-vpc
terraform destroy -var="aws_region=<REGION>"
```

---

## Key Variables (eks-monitoring module)

| Variable | Default | Description |
|----------|---------|-------------|
| `collector_profile` | (required) | `cloudwatch-otlp`, `managed-metrics`, or `self-managed-amp` |
| `eks_cluster_id` | (required) | EKS cluster name |
| `cloudwatch_metrics_endpoint` | regional default | Override CloudWatch OTLP endpoint URL |
| `create_amp_workspace` | `true` | Create new AMP workspace (AMP profiles) |
| `enable_dashboards` | `true` | Provision Grafana dashboards |
| `enable_tracing` | `true` | Enable X-Ray traces (self-managed-amp) |
| `enable_logs` | `true` | Enable CloudWatch Logs (self-managed-amp) |

## IAM Notes

- **cloudwatch-otlp**: IRSA role with `cloudwatch:PutMetricData` for the OTel Collector
- **self-managed-amp**: IRSA role with AMP remote write, X-Ray, and CW Logs policies
- **managed-metrics**: No in-cluster IAM — managed scraper uses its own service-linked role

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No metrics in Grafana | Collector not running | Check pods in collector namespace |
| 504 on Grafana datasource | SigV4 auth misconfigured | Check Grafana workspace IAM role |
| Dashboards show "No data" | Metrics not yet ingested | Wait 5 min, check collector logs |
| OTel Collector CrashLoopBackOff | Missing IRSA permissions | Check IAM role trust policy and policies |
| ECR image pull errors | Missing ECR policy | Verify `AmazonEC2ContainerRegistryReadOnly` on node role |
| AMP scraper not collecting | Network access | Check security groups allow scraper → EKS API |
