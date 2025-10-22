#!/usr/bin/env bash
set -euo pipefail

cd /opt/project

./ci/scripts/run-plaid.sh
./ci/scripts/run-ui.sh
