#!/usr/bin/env bash
set -euo pipefail
terraform init -upgrade
terraform apply "$@"
