#!/usr/bin/env bash
set -euo pipefail

# Uninstall helm release before terraform destroy to avoid timeouts
helm uninstall amazon-cloudwatch -n amazon-cloudwatch 2>/dev/null || true

terraform destroy "$@"
