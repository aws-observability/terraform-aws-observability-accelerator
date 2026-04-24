# AGENT.md — AI Agent Instructions for AWS Observability Accelerator

You are helping a user deploy EKS observability using this Terraform repository.
Your job is to guide them through deployment conversationally — gather the info
you need, provision prerequisites, run Terraform, and hand them working dashboard URLs.

## Repository Structure

```
modules/eks-monitoring/          # Core module — all profiles
examples/
  managed-grafana-workspace/     # Prereq: create a Grafana workspace + API token
  eks-cloudwatch-otlp/           # CloudWatch OTLP via EKS add-on (public-ready)
  eks-cloudwatch-container-insights/  # Standalone CW Agent add-on example
  eks-amp-managed/               # AMP with managed collector (agentless)
  eks-amp-otel/                  # AMP with self-managed OTel Collector
dashboards/
  cloudwatch-otlp/               # Container Insights dashboards (CW Agent add-on)
  original/                      # Standard Prometheus dashboards (AMP profiles)
```

## Collector Profiles

| Profile | Collector | Backend | Example | Status |
|---------|-----------|---------|---------|--------|
| `cloudwatch-otlp` | CW Agent EKS add-on | CloudWatch OTLP endpoint | `eks-cloudwatch-otlp/` | Public-ready |
| `managed-metrics` | AMP Managed Scraper (agentless) | AMP | `eks-amp-managed/` | Public-ready |
| `self-managed-amp` | OTel Collector (Helm) | AMP | `eks-amp-otel/` | Public-ready |

### Profile details

**`cloudwatch-otlp`** (recommended for CloudWatch users)
- Deploys the `amazon-cloudwatch-observability` EKS add-on via `aws_eks_addon`
- Add-on includes: CW Agent DaemonSet, Fluent Bit, kube-state-metrics, node-exporter
- Enhanced Container Insights enabled by default
- IAM via EKS Pod Identity — the add-on manages the association inline
- **Prerequisite**: `eks-pod-identity-agent` add-on must be installed on the cluster
- Uses `cloudwatch-otlp/` dashboards (9 dashboards in "CloudWatch Container Insights" folder)
- Dashboards: cluster, containers, gpu-fleet, kubelet, namespace-workloads,
  node-exporter, nodes, unified-service, workloads

**`managed-metrics`** (recommended for AMP users wanting zero management)
- AMP managed scraper — no in-cluster collector to manage
- Requires at least 2 subnets in 2 AZs
- Uses `original/` dashboards with an AMP datasource
- Supports `additional_scrape_jobs` for custom scrape targets

**`self-managed-amp`** (full control)
- OTel Collector with AMP remote write, optional X-Ray traces + CW Logs
- IRSA role with AMP, X-Ray, and CW Logs policies
- Uses `original/` dashboards with an AMP datasource

---

## Quick Start (Demo Scripts)

For a zero-to-demo setup, use the scripts in `demo/`:

| Script | Purpose |
|--------|---------|
| `demo/config.sh` | Set `AWS_REGION` and `CLUSTER_NAME` (defaults: `us-east-1`, `cw-otlp-demo`) |
| `demo/setup.sh` | End-to-end setup: EKS cluster → Grafana → CloudWatch OTLP monitoring → Python demo app |
| `demo/teardown.sh` | Destroys everything in reverse order |

```bash
# 1. Configure (optional — edit region/cluster name)
vi demo/config.sh

# 2. Run
cd demo/
./setup.sh
```

The scripts are re-entrant: re-running skips already-completed steps.

**Prerequisites** (auto-checked by setup.sh): `aws`, `eksctl`, `kubectl`, `terraform`, `docker`

```bash
brew install weaveworks/tap/eksctl kubectl
brew install --cask docker   # then open Docker Desktop once
```

---

## Deployment Playbook

For manual or partial deployments, follow these steps in order. Each step
checks whether the resource exists before creating it.

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

If the user has no cluster, create one with eksctl:

```bash
eksctl create cluster \
  --name <NAME> \
  --region <REGION> \
  --version 1.32 \
  --nodegroup-name system \
  --node-type t3.medium \
  --nodes 2 \
  --managed
```

### Step 1b: EKS Pod Identity Agent (required for cloudwatch-otlp)

The `cloudwatch-otlp` profile uses EKS Pod Identity for IAM. Check if the
Pod Identity Agent is installed:

```bash
aws eks list-addons --cluster-name <NAME> --region <REGION>
```

If `eks-pod-identity-agent` is not in the list, install it:

```bash
aws eks create-addon --cluster-name <NAME> --addon-name eks-pod-identity-agent --region <REGION>
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

**Important**: A new workspace has no users by default. After creating the
workspace, assign a user via the AWS console or CLI:

```bash
aws grafana update-permissions \
  --workspace-id <WORKSPACE_ID> \
  --update-instruction-batch \
    'action=ADD,role=ADMIN,users=[{id=<SSO_USER_ID>,type=SSO_USER}]' \
  --region <REGION>
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
terraform init
terraform apply

# With dashboards
terraform apply \
  -var="grafana_endpoint=<ENDPOINT>" \
  -var="grafana_api_key=<KEY>"
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

### Step 4: Verify and Hand Over

After a successful apply, walk the user through verification.

#### 4a. Check deployed components

For `cloudwatch-otlp`:
```bash
echo "=== CW Agent ==="
kubectl get pods -n amazon-cloudwatch

echo ""
echo "=== CW Agent logs (check for credential errors) ==="
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=cloudwatch-agent --tail=20
```

For AMP profiles:
```bash
echo "=== OTel Collector ==="
kubectl get pods -n otel-collector

echo ""
echo "=== kube-state-metrics ==="
kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-state-metrics

echo ""
echo "=== node-exporter ==="
kubectl get pods -n prometheus-node-exporter
```

For `managed-metrics` (no in-cluster collector):
```bash
aws amp list-scrapers --region <REGION> \
  --query 'scrapers[*].{id:scraperId,status:status.statusCode}'
```

#### 4b. Recap for the user

Present a summary like this:

For `cloudwatch-otlp`:
```
✅ Deployment complete!

Components:
  - CW Agent add-on:  amazon-cloudwatch namespace (DaemonSet)
  - Fluent Bit:        amazon-cloudwatch namespace (DaemonSet)
  - kube-state-metrics: bundled in add-on
  - node-exporter:     bundled in add-on

CloudWatch Console:
  → Container Insights should show data within 3-5 minutes

Grafana: https://<WORKSPACE_ENDPOINT>
  → Log in via AWS IAM Identity Center (SSO)
  → Dashboards in "CloudWatch Container Insights" folder
```

---

## Optional: Deploy a Sample App (Python OTel SDK)

After the base monitoring is running, deploy a sample application instrumented
with the OpenTelemetry SDK to see custom metrics flowing through the OTLP
pipeline. The [aws-otel-community](https://github.com/aws-observability/aws-otel-community)
repository provides a Python app that emits six metrics covering all OTel types:

| Metric | Type | Description |
|--------|------|-------------|
| `total_bytes_sent` | Counter | Bytes sent per API request |
| `total_api_requests` | Async Counter | Total API request count |
| `latency_time` | Histogram | API latency (buckets: 100, 300, 500ms) |
| `time_alive` | Counter | Application uptime |
| `cpu_usage` | Gauge | Simulated CPU usage |
| `threads_active` | UpDownCounter | Active thread count |
| `total_heap_size` | Gauge | Current heap size |

### Build and push the image

```bash
git clone https://github.com/aws-observability/aws-otel-community.git
cd aws-otel-community/sample-apps/python-auto-instrumentation-sample-app

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-1

aws ecr create-repository --repository-name python-demo-app --region $REGION 2>/dev/null || true
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build --platform linux/amd64 -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/python-demo-app:latest .
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/python-demo-app:latest
```

### Deploy the application

Create `demo-app.yaml` (replace `<ACCOUNT_ID>` and `<REGION>`):

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-demo-app
  namespace: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: python-demo-app
  template:
    metadata:
      labels:
        app: python-demo-app
    spec:
      containers:
        - name: python-demo-app
          image: <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/python-demo-app:latest
          ports:
            - containerPort: 8080
          env:
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: http://cwa-otlp-gateway.amazon-cloudwatch:4315
            - name: OTEL_RESOURCE_ATTRIBUTES
              value: service.namespace=demo,service.name=python-demo-app
---
apiVersion: v1
kind: Service
metadata:
  name: python-demo-app
  namespace: demo-app
spec:
  selector:
    app: python-demo-app
  ports:
    - port: 8080
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-generator
  namespace: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traffic-generator
  template:
    metadata:
      labels:
        app: traffic-generator
    spec:
      containers:
        - name: traffic-gen
          image: ellerbrock/alpine-bash-curl-ssl:latest
          args:
            - /bin/bash
            - -c
            - >-
              sleep 15; while :; do
              curl -s python-demo-app:8080/outgoing-http-call > /dev/null 2>&1; sleep 2;
              curl -s python-demo-app:8080/ > /dev/null 2>&1; sleep 1;
              done
```

```bash
kubectl apply -f demo-app.yaml
kubectl get pods -n demo-app
```

### Query metrics in Grafana

Open Grafana → Explore → select the CloudWatch PromQL datasource.

All metrics from the demo app:
```promql
{@resource.service.name="python-demo-app"}
```

p99 latency by AWS region:
```promql
histogram_quantile(0.99, sum by (le, `@aws.region`) (rate({__name__="latency_time", `@resource.service.name`="python-demo-app"}[5m])))
```

Bytes sent rate:
```promql
sum by (`@resource.service.name`) (rate({__name__="total_bytes_sent"}[5m]))
```

### Cleanup

```bash
kubectl delete namespace demo-app
```

---

## Vended Metrics Enrichment (CloudWatch OTLP)

CloudWatch OTel enrichment adds AWS resource attributes (account, region, service)
to vended metrics. This is a one-time account-level enablement.

```bash
# Step 1: Enable telemetry enrichment
aws observabilityadmin start-telemetry-enrichment

# Step 2: Enable OTel enrichment
aws cloudwatch start-o-tel-enrichment
```

Both commands are idempotent. Run them once per account before deploying the
`cloudwatch-otlp` profile for full metric attribution in dashboards.

---

## Cleanup

If you used the demo scripts:

```bash
cd demo/
./teardown.sh
```

For manual teardown, destroy in reverse order:

```bash
# Demo app (if deployed)
kubectl delete namespace demo-app

# Monitoring
cd examples/eks-cloudwatch-otlp  # or eks-amp-managed, eks-amp-otel
terraform destroy \
  -var="grafana_endpoint=<ENDPOINT>" \
  -var="grafana_api_key=<KEY>"

# Grafana (if created)
cd ../managed-grafana-workspace
terraform destroy -var="aws_region=<REGION>"

# Cluster (if created with eksctl)
eksctl delete cluster --name <NAME> --region <REGION>
```

> **Note**: Always pass real Grafana credentials to `terraform destroy` for the
> monitoring step — Terraform needs to connect to Grafana to delete dashboards
> and datasources. Passing placeholder values will cause the destroy to fail.

---

## Key Variables (eks-monitoring module)

| Variable | Default | Description |
|----------|---------|-------------|
| `collector_profile` | (required) | `cloudwatch-otlp`, `managed-metrics`, or `self-managed-amp` |
| `eks_cluster_id` | (required) | EKS cluster name |
| `cw_agent_addon_version` | cluster default | Override CW Agent add-on version |
| `cw_agent_enable_container_logs` | `true` | Enable Fluent Bit container logs |
| `cw_agent_enable_application_signals` | `false` | Enable Application Signals auto-instrumentation |
| `cloudwatch_metrics_endpoint` | regional default | Override CloudWatch OTLP endpoint URL |
| `enable_otlp_gateway` | `false` | Deploy CWA as OTLP gateway for app metrics (cloudwatch-otlp) |
| `create_amp_workspace` | `true` | Create new AMP workspace (AMP profiles) |
| `enable_dashboards` | `true` | Provision Grafana dashboards |
| `enable_tracing` | `true` | Enable X-Ray traces (self-managed-amp) |
| `enable_logs` | `true` | Enable CloudWatch Logs (self-managed-amp) |
| `additional_scrape_jobs` | `[]` | Extra Prometheus scrape jobs (managed-metrics, self-managed-amp) |

## IAM Notes

- **cloudwatch-otlp**: Pod Identity role with `CloudWatchAgentServerPolicy`, managed inline by the `aws_eks_addon` resource. Requires `eks-pod-identity-agent` add-on.
- **self-managed-amp**: IRSA role with AMP remote write, X-Ray, and CW Logs policies
- **managed-metrics**: No in-cluster IAM — managed scraper uses its own service-linked role

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `NoCredentialProviders` in CW Agent logs | Pod Identity not configured | Ensure `eks-pod-identity-agent` add-on is installed on the cluster |
| No metrics in CloudWatch console | Agent not sending data | Check CW Agent logs for errors |
| No metrics in Grafana | Datasource misconfigured | Check CloudWatch PromQL datasource SigV4 settings |
| Dashboards show "No data" | Metrics not yet ingested | Wait 5 min, check agent logs |
| OTel Collector CrashLoopBackOff | Missing IRSA permissions | Check IAM role trust policy and policies |
| AMP scraper not collecting | Network access | Check security groups allow scraper → EKS API |
