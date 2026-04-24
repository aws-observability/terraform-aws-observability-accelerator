#!/usr/bin/env bash
# Demo configuration — edit these before running setup.sh

export AWS_REGION="us-east-1"
export CLUSTER_NAME="cw-otlp-demo"

# Derived (do not edit)
export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null)"
