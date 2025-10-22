#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ -d .venv ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

status=0
python -W ignore -m robot --console quiet -d reports/all tests || status=$?

python - <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path

report_path = Path("reports/all/output.xml")
if not report_path.exists():
    print("No Robot output found at reports/all/output.xml")
    raise SystemExit(1)

root = ET.parse(report_path).getroot()
top_suite = root.find("suite")
if top_suite is None:
    print("Unexpected Robot output format")
    raise SystemExit(1)

def summarize(suite):
    passed = failed = skipped = 0
    for test in suite.iter("test"):
        status = test.find("status").attrib.get("status", "")
        if status == "PASS":
            passed += 1
        elif status == "FAIL":
            failed += 1
        elif status == "SKIP":
            skipped += 1
    return passed, failed, skipped

def format_line(name, suite):
    passed, failed, skipped = summarize(suite)
    parts = [f"{passed} passed", f"{failed} failed"]
    if skipped:
        parts.append(f"{skipped} skipped")
    return f"{name} Tests: {', '.join(parts)}"

LABEL_MAP = {
    "E2E": "E2E",
    "Integration": "Integration",
    "Unit": "Unit",
}

print("\n" + "=" * 50)
print("Robot Test Summary")
print("=" * 50)

for child in top_suite.findall("suite"):
    raw_name = child.attrib.get("name", "Suite")
    pretty_name = LABEL_MAP.get(raw_name, raw_name)
    print(format_line(pretty_name, child))

print("-" * 50)
print(format_line("All", top_suite))
print("=" * 50)
print()
PY

exit "${status}"
