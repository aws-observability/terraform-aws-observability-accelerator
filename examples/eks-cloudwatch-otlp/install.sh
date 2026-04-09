#!/usr/bin/env bash
set -euo pipefail

# Install EKS CloudWatch OTLP observability.
#
# Usage:
#   ./install.sh -var="eks_cluster_id=my-cluster"
#
# To include Grafana dashboards, pass the workspace outputs:
#   ./install.sh \
#     -var="eks_cluster_id=my-cluster" \
#     -var="grafana_endpoint=https://g-xxx.grafana-workspace.us-east-1.amazonaws.com" \
#     -var="grafana_api_key=glsa_xxx"
#
# All arguments are forwarded to terraform apply.

terraform init -upgrade
terraform apply "$@"
