#!/usr/bin/env bash
set -euo pipefail

PABOT_PROCESSES="${PABOT_PROCESSES:-4}"

cd /opt/project

echo "Running Automation Exercise UI suite with ${PABOT_PROCESSES} parallel workers (test-level split)..."
mkdir -p reports || true
mkdir -p reports/ui_parallel
pabot --processes "${PABOT_PROCESSES}" \
      --testlevelsplit \
      --outputdir reports/ui_parallel \
      tests/ui

echo "UI suite completed. Reports stored in reports/ui_parallel." 
