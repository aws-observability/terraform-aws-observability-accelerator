# EKS CloudWatch OTLP Example

Deploys EKS observability via the Amazon CloudWatch Observability EKS add-on,
with optional Grafana dashboards in a "CloudWatch Container Insights" folder.

## What gets deployed

- `amazon-cloudwatch-observability` EKS add-on (CW Agent DaemonSet, Fluent Bit, kube-state-metrics, node-exporter)
- IAM role for Pod Identity with `CloudWatchAgentServerPolicy`
- OTLP gateway (optional) — CWA Deployment accepting app OTLP metrics and forwarding to CloudWatch via `otlphttp` + SigV4
- Grafana dashboards (9 dashboards) — when Grafana endpoint is provided

## Prerequisites

### 1. EKS cluster

You need a running EKS cluster with at least one managed node group.

```bash
eksctl create cluster --name my-cluster --region us-east-1 --version 1.32 \
  --nodegroup-name system --node-type t3.medium --nodes 2 --managed
```

### 2. EKS Pod Identity Agent add-on

The CW Agent uses EKS Pod Identity for IAM credentials. Install the agent:

```bash
aws eks create-addon --cluster-name my-cluster --addon-name eks-pod-identity-agent --region us-east-1
```

### 3. Grafana workspace (optional — for dashboards)

To provision dashboards, you need an Amazon Managed Grafana workspace with a
service account token. Use the [`managed-grafana-workspace`](../managed-grafana-workspace/)
example.

### 4. Terraform >= 1.5

## Quick start

CW Agent only (no dashboards):

```bash
terraform init
terraform apply -var="eks_cluster_id=my-cluster" -var="aws_region=us-east-1"
```

With Grafana dashboards:

```bash
terraform apply \
  -var="eks_cluster_id=my-cluster" \
  -var="aws_region=us-east-1" \
  -var="grafana_endpoint=https://g-xxxxx.grafana-workspace.us-east-1.amazonaws.com" \
  -var="grafana_api_key=glsa_xxxxx"
```

## Verify

```bash
# Add-on status
aws eks describe-addon --cluster-name my-cluster \
  --addon-name amazon-cloudwatch-observability --region us-east-1 \
  --query '{status:addon.status,version:addon.addonVersion}'

# Pods running
kubectl get pods -n amazon-cloudwatch

# Agent logs (check for credential errors)
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=cloudwatch-agent --tail=20
```

Metrics should appear in the CloudWatch console under Container Insights within 3-5 minutes.

## Deploy a demo app (optional)

To see custom application metrics alongside Container Insights, deploy the
[aws-otel-community](https://github.com/aws-observability/aws-otel-community)
Python sample app. It emits 7 metrics (counter, histogram, gauge, up-down counter).

Build and push the image:

```bash
git clone https://github.com/aws-observability/aws-otel-community.git
cd aws-otel-community/sample-apps/python-auto-instrumentation-sample-app

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository --repository-name python-demo-app --region us-east-1 2>/dev/null || true
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
docker build --platform linux/amd64 -t $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/python-demo-app:latest .
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/python-demo-app:latest
```

Deploy (replace `<ACCOUNT_ID>`):

```bash
kubectl create namespace demo-app
kubectl apply -n demo-app -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-demo-app
spec:
  replicas: 1
  selector:
    matchLabels: { app: python-demo-app }
  template:
    metadata:
      labels: { app: python-demo-app }
    spec:
      containers:
        - name: app
          image: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/python-demo-app:latest
          ports: [{ containerPort: 8080 }]
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
spec:
  selector: { app: python-demo-app }
  ports: [{ port: 8080 }]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-generator
spec:
  replicas: 1
  selector:
    matchLabels: { app: traffic-generator }
  template:
    metadata:
      labels: { app: traffic-generator }
    spec:
      containers:
        - name: gen
          image: ellerbrock/alpine-bash-curl-ssl:latest
          args: ["/bin/bash", "-c", "sleep 15; while :; do curl -s python-demo-app:8080/outgoing-http-call > /dev/null 2>&1; sleep 2; curl -s python-demo-app:8080/ > /dev/null 2>&1; sleep 1; done"]
EOF
```

Query in Grafana (Explore → CloudWatch PromQL datasource):

```promql
{@resource.service.name="python-demo-app"}
```

## Outputs

| Name | Description |
|------|-------------|
| `cloudwatch_promql_datasource` | Datasource connection details for Grafana |
| `otlp_gateway_endpoint` | OTLP gateway gRPC/HTTP endpoints for app telemetry |

## Cleanup

```bash
terraform destroy -var="eks_cluster_id=my-cluster" -var="aws_region=us-east-1"
```
