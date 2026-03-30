#!/usr/bin/env bash
set -euo pipefail

# Destroy all resources created by install.sh.
#
# Usage:
#   ./destroy.sh -var="eks_cluster_id=my-cluster"
#
# All arguments are forwarded to terraform destroy.

terraform destroy "$@"
