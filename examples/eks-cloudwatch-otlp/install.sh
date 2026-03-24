#!/usr/bin/env bash
set -euo pipefail

# Two-phase install for EKS CloudWatch OTLP observability.
# Phase 1: Create Grafana workspace, CloudWatch Agent, supporting infra.
# Phase 2: Use the Grafana token from Phase 1 to provision dashboards.
#
# Usage:
#   ./install.sh -var="eks_cluster_id=my-cluster" -var="aws_region=us-west-2"
#
# All arguments are forwarded to terraform apply.

EXTRA_ARGS=("$@")

echo "=== Phase 1: Infrastructure (Grafana workspace + CloudWatch Agent) ==="
terraform init -upgrade
terraform apply "${EXTRA_ARGS[@]}"

echo ""
echo "=== Phase 2: Provision dashboards ==="
GRAFANA_ENDPOINT=$(terraform output -raw grafana_workspace_endpoint)
GRAFANA_API_KEY=$(terraform output -raw grafana_api_key)

terraform apply \
  -var="grafana_endpoint=${GRAFANA_ENDPOINT}" \
  -var="grafana_api_key=${GRAFANA_API_KEY}" \
  "${EXTRA_ARGS[@]}"

echo ""
echo "=== Done ==="
echo "Grafana: ${GRAFANA_ENDPOINT}"
echo "EKS Cluster: $(terraform output -raw eks_cluster_id 2>/dev/null || echo 'N/A')"
