#!/usr/bin/env bash
set -euo pipefail

cd /opt/project

mkdir -p reports
mkdir -p reports/plaid_parallel
mkdir -p reports/ui_parallel

./ci/scripts/run-plaid.sh
./ci/scripts/run-ui.sh
