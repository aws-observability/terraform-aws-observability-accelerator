#!/usr/bin/env bash
set -euo pipefail

# Uninstall helm releases before terraform destroy to avoid timeouts
helm uninstall otel-collector -n otel-collector 2>/dev/null || true
helm uninstall kube-state-metrics -n kube-system 2>/dev/null || true
helm uninstall prometheus-node-exporter -n prometheus-node-exporter 2>/dev/null || true

terraform destroy "$@"
