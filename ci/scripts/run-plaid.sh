#!/usr/bin/env bash
set -euo pipefail

# Default to 4 processes if not provided
PABOT_PROCESSES="${PABOT_PROCESSES:-4}"

cd /opt/project

echo "Running Plaid contract suites with ${PABOT_PROCESSES} parallel workers..."
pabot --processes "${PABOT_PROCESSES}" \
      --outputdir reports/plaid_parallel \
      tests/unit tests/e2e

echo "Plaid suites completed."
