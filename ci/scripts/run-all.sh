#!/usr/bin/env bash
set -euo pipefail

cd /opt/project

mkdir -p reports || true
mkdir -p reports/plaid_parallel || true
mkdir -p reports/ui_parallel || true

./ci/scripts/run-plaid.sh
./ci/scripts/run-ui.sh
