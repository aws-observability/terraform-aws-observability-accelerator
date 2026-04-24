#!/usr/bin/env bash
# End-to-end CloudWatch OTLP demo setup.
#
# Runs four steps in order:
#   1. EKS cluster + Pod Identity Agent
#   2. Amazon Managed Grafana workspace
#   3. CloudWatch OTLP monitoring (eks-cloudwatch-otlp)
#   4. Python demo app + traffic generator
#
# Usage:
#   cd demo/
#   # Edit config.sh with your region / cluster name first
#   ./setup.sh
#
# Re-entrant: each step is skipped when it's already done.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

GRAFANA_DIR="$REPO_ROOT/examples/managed-grafana-workspace"
MONITORING_DIR="$REPO_ROOT/examples/eks-cloudwatch-otlp"

# ── helpers ──────────────────────────────────────────────────────────────────

step() { echo; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "  $*"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }
check_prereqs() {
  local missing=()
  for cmd in aws eksctl kubectl terraform; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: missing required tools: ${missing[*]}"
    echo "Install guides:"
    echo "  aws:       https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    echo "  eksctl:    https://eksctl.io/installation/"
    echo "  kubectl:   https://kubernetes.io/docs/tasks/tools/"
    echo "  terraform: https://developer.hashicorp.com/terraform/install"
    exit 1
  fi
}

# ── preflight ────────────────────────────────────────────────────────────────

check_prereqs

echo
echo "Demo config:"
echo "  AWS_REGION   = $AWS_REGION"
echo "  CLUSTER_NAME = $CLUSTER_NAME"
echo "  ACCOUNT_ID   = $ACCOUNT_ID"
echo
read -r -p "Proceed? [y/N] " confirm
[[ "$confirm" == "y" || "$confirm" == "Y" ]] || { echo "Aborted."; exit 0; }

# ── step 1: EKS cluster ───────────────────────────────────────────────────────

step "1/4 — EKS cluster: $CLUSTER_NAME"

CLUSTER_STATUS=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" \
  --query 'cluster.status' --output text 2>/dev/null || echo "NOT_FOUND")

if [[ "$CLUSTER_STATUS" == "ACTIVE" ]]; then
  echo "Cluster already ACTIVE — skipping creation."
else
  echo "Creating EKS cluster (this takes ~15 minutes)…"
  eksctl create cluster \
    --name "$CLUSTER_NAME" \
    --region "$AWS_REGION" \
    --version 1.32 \
    --nodegroup-name system \
    --node-type t3.medium \
    --nodes 2 \
    --managed

  aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
fi

# Pod Identity Agent
ADDON_STATUS=$(aws eks describe-addon --cluster-name "$CLUSTER_NAME" \
  --addon-name eks-pod-identity-agent --region "$AWS_REGION" \
  --query 'addon.status' --output text 2>/dev/null || echo "NOT_FOUND")

if [[ "$ADDON_STATUS" == "ACTIVE" ]]; then
  echo "Pod Identity Agent add-on already ACTIVE — skipping."
else
  echo "Installing Pod Identity Agent add-on…"
  aws eks create-addon \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name eks-pod-identity-agent \
    --region "$AWS_REGION"

  echo "Waiting for Pod Identity Agent to become ACTIVE…"
  aws eks wait addon-active \
    --cluster-name "$CLUSTER_NAME" \
    --addon-name eks-pod-identity-agent \
    --region "$AWS_REGION"
fi

# ── step 2: Amazon Managed Grafana ───────────────────────────────────────────

step "2/4 — Amazon Managed Grafana workspace"

cd "$GRAFANA_DIR"
terraform init -upgrade -input=false
terraform apply -auto-approve -input=false -var="aws_region=$AWS_REGION"

GRAFANA_ENDPOINT=$(terraform output -raw grafana_workspace_endpoint)
GRAFANA_API_KEY=$(terraform output -raw grafana_api_key)

echo
echo "Grafana endpoint : $GRAFANA_ENDPOINT"
echo "API key          : (sensitive — stored in Terraform state)"

# ── step 3: CloudWatch OTLP monitoring ───────────────────────────────────────

step "3/4 — CloudWatch OTLP monitoring"

cd "$MONITORING_DIR"
terraform init -upgrade -input=false
terraform apply -auto-approve -input=false \
  -var="eks_cluster_id=$CLUSTER_NAME" \
  -var="aws_region=$AWS_REGION" \
  -var="grafana_endpoint=$GRAFANA_ENDPOINT" \
  -var="grafana_api_key=$GRAFANA_API_KEY"

OTLP_ENDPOINT=$(terraform output -raw otlp_gateway_endpoint 2>/dev/null || echo "")

echo
echo "OTLP gateway : ${OTLP_ENDPOINT:-not deployed (enable_otlp_gateway=false)}"

# ── step 4: demo app ─────────────────────────────────────────────────────────

step "4/4 — Python demo app + traffic generator"

aws ecr create-repository \
  --repository-name python-demo-app \
  --region "$AWS_REGION" 2>/dev/null || true

ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/python-demo-app:latest"

if docker manifest inspect "$ECR_URI" &>/dev/null 2>&1; then
  echo "Image already in ECR — skipping build."
else
  echo "Cloning aws-otel-community sample app…"
  TMP=$(mktemp -d)
  git clone --depth 1 https://github.com/aws-observability/aws-otel-community.git "$TMP/aws-otel-community"

  echo "Building and pushing image…"
  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

  docker build --platform linux/amd64 \
    -t "$ECR_URI" \
    "$TMP/aws-otel-community/sample-apps/python-auto-instrumentation-sample-app"

  docker push "$ECR_URI"
  rm -rf "$TMP"
fi

echo "Deploying demo app to EKS…"
kubectl create namespace demo-app --dry-run=client -o yaml | kubectl apply -f -

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
          image: ${ECR_URI}
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
          args:
            - /bin/bash
            - -c
            - "sleep 15; while :; do curl -s python-demo-app:8080/outgoing-http-call >/dev/null 2>&1; sleep 2; curl -s python-demo-app:8080/ >/dev/null 2>&1; sleep 1; done"
EOF

# ── summary ───────────────────────────────────────────────────────────────────

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Demo ready"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "  Grafana        : $GRAFANA_ENDPOINT"
echo "  OTLP gateway   : ${OTLP_ENDPOINT:-n/a}"
echo
echo "Verify:"
echo "  kubectl get pods -n amazon-cloudwatch"
echo "  kubectl get pods -n demo-app"
echo
echo "Grafana Explore query (wait ~3-5 min for first metrics):"
echo "  {@resource.service.name=\"python-demo-app\"}"
echo
