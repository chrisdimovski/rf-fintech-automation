# rf-fintech Automation Suite

Comprehensive Robot Framework automation that covers Plaid sandbox contracts (unit, integration, and e2e) and Automation Exercise UI smoke tests powered by Playwright.

---

## Prerequisites

- Python 3.11+
- Node.js + npm (required for `robotframework-browser`)
- Docker Desktop (optional, recommended for consistent runs)
- Plaid sandbox credentials
  - `PLAID_CLIENT_ID`
  - `PLAID_SECRET`
  - `PLAID_WEBHOOK_URL` (use a valid 200-returning endpoint such as webhook.site)

## Installation

```bash
pip install -r requirements.txt
# download Playwright browsers
rfbrowser init chromium
```

## Running Tests Locally (Python)

> Pabot is already included in `requirements.txt`; use `--processes` to control parallelism.

### Contract suites (unit + integration + e2e)

```bash
python -m pabot --processes 4 --outputdir reports/plaid_parallel tests/unit tests/integration tests/e2e
```

### Individual contract layers

```bash
python -m robot -d reports/unit tests/unit
python -m robot -d reports/integration tests/integration
python -m robot -d reports/e2e tests/e2e
```

### UI smoke tests

Browsers run **headed** by default for easy debugging. Set `PLAYWRIGHT_HEADLESS=true` to run faster.

```bash
python -m robot -d reports/ui tests/ui/automation_exercise.robot
# Parallelised test-level execution
PLAYWRIGHT_HEADLESS=true python -m pabot --processes 4 --testlevelsplit --outputdir reports/ui_parallel tests/ui
```

## Docker Execution (recommended for speed & parity)

```bash
docker compose build

# Contract suites (unit + integration + e2e)
docker compose run --rm robot ./ci/scripts/run-plaid.sh

# UI suite (set PLAYWRIGHT_HEADLESS=false to watch the browser)
PLAYWRIGHT_HEADLESS=false docker compose run --rm robot ./ci/scripts/run-ui.sh

# Everything
docker compose run --rm robot ./ci/scripts/run-all.sh
```

*Tips for fastest runs*
- Keep Docker image warm (compose caches dependencies).
- Increase `PABOT_PROCESSES` environment variable to match available CPUs.
- Use headless Playwright (`PLAYWRIGHT_HEADLESS=true`) in CI or Docker for best performance.

## CI/CD Workflow

GitHub Actions workflow: `.github/workflows/tests.yml`

- Builds the Playwright-enabled Docker image (with buildx caching).
- Matrix jobs execute contract suites and UI suite in parallel.
- Artifacts (`reports-plaid` / `reports-ui`) contain Robot `log.html`, `report.html`, `output.xml`.
- Remember to configure repo secrets: `PLAID_CLIENT_ID`, `PLAID_SECRET`, `PLAID_WEBHOOK_URL`.

## Helpful Docs

- [`docs/ui-automation.md`](docs/ui-automation.md) – detailed overview of the UI POM structure, Docker commands, and CI pipeline.
- `ci/scripts/*` – wrappers used in Docker/CI to run suites with Pabot.

---

Happy testing!
