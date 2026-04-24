#!/usr/bin/env bash
# Tear down the CloudWatch OTLP demo in reverse order.
#
# Usage:
#   cd demo/
#   ./teardown.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

GRAFANA_DIR="$REPO_ROOT/examples/managed-grafana-workspace"
MONITORING_DIR="$REPO_ROOT/examples/eks-cloudwatch-otlp"

step() { echo; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "  $*"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

echo
echo "This will destroy:"
echo "  - EKS cluster: $CLUSTER_NAME (region: $AWS_REGION)"
echo "  - Amazon Managed Grafana workspace"
echo "  - All Terraform-managed resources"
echo
read -r -p "Are you sure? [y/N] " confirm
[[ "$confirm" == "y" || "$confirm" == "Y" ]] || { echo "Aborted."; exit 0; }

# 1. Demo app
step "Removing demo app"
kubectl delete namespace demo-app --ignore-not-found=true

# 2. CloudWatch OTLP monitoring
step "Destroying CloudWatch OTLP monitoring"
cd "$MONITORING_DIR"
if [[ -f terraform.tfstate ]]; then
  # Read real Grafana creds from the workspace state so the provider can
  # connect and actually destroy dashboards/datasources/folders.
  GRAFANA_ENDPOINT=$(cd "$GRAFANA_DIR" && terraform output -raw grafana_workspace_endpoint 2>/dev/null || echo "")
  GRAFANA_API_KEY=$(cd "$GRAFANA_DIR" && terraform output -raw grafana_api_key 2>/dev/null || echo "")

  if [[ -z "$GRAFANA_ENDPOINT" ]]; then
    echo "Could not read Grafana endpoint from state — removing Grafana resources from state and destroying the rest."
    terraform state rm \
      "module.eks_monitoring.grafana_folder.this[0]" \
      "module.eks_monitoring.grafana_data_source.cloudwatch_promql[0]" \
      "module.eks_monitoring.grafana_data_source.cloudwatch_logs[0]" \
      "module.eks_monitoring.grafana_data_source.xray[0]" 2>/dev/null || true
    # Remove any dashboard resources from state
    terraform state list 2>/dev/null | grep "grafana_dashboard" | xargs -I{} terraform state rm "{}" 2>/dev/null || true
    GRAFANA_ENDPOINT="https://placeholder.grafana.local"
    GRAFANA_API_KEY="placeholder"
  fi

  terraform destroy -auto-approve -input=false \
    -var="eks_cluster_id=$CLUSTER_NAME" \
    -var="aws_region=$AWS_REGION" \
    -var="grafana_endpoint=$GRAFANA_ENDPOINT" \
    -var="grafana_api_key=$GRAFANA_API_KEY"
else
  echo "No Terraform state found — skipping."
fi

# 3. Managed Grafana
step "Destroying Managed Grafana workspace"
cd "$GRAFANA_DIR"
if [[ -f terraform.tfstate ]]; then
  terraform destroy -auto-approve -input=false -var="aws_region=$AWS_REGION"
else
  echo "No Terraform state found — skipping."
fi

# 4. EKS cluster
step "Deleting EKS cluster: $CLUSTER_NAME"
CLUSTER_STATUS=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" \
  --query 'cluster.status' --output text 2>/dev/null || echo "NOT_FOUND")

if [[ "$CLUSTER_STATUS" == "NOT_FOUND" ]]; then
  echo "Cluster not found — skipping."
else
  eksctl delete cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --wait
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Teardown complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
