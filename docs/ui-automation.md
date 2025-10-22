# Automated Test Overview

This document captures the two major automation layers currently in the repository:

1. **Plaid contract tests** – Robot suites that exercise sandbox APIs and automatically manage credentials.
2. **Automation Exercise UI smoke tests** – Playwright-driven browser checks wrapped in Robot Framework page objects.

Both run in Robot Framework and are laid out to keep credentials, selectors, and flows maintainable.

---

## Plaid Contract Tests

### Credential handling

- `resources/services/plaid.robot` now bootstraps `PLAID_CLIENT_ID` and `PLAID_SECRET` from `.env` whenever they are missing in the shell. Keep your sandbox credentials in `rf-fintech/.env`:

  ```env
  PLAID_CLIENT_ID=68f3...
  PLAID_SECRET=c6fe...
  PLAID_WEBHOOK_URL=https://your-webhook-endpoint
  ```

- The suite sets the values as environment variables for the active Robot run. No manual `export` is required.

- The helper keyword also filters noisy TLS warnings from urllib3 so test output stays readable.

### Runner script

Use the wrapper to execute every Plaid unit/e2e suite and see a concise summary:

```bash
cd /Users/kristijandimovski/Desktop/RF-FINTECH/rf-fintech
source .venv/bin/activate
./ci/run_robot.sh
```

The script will:

1. Run `robot --console quiet -d reports/all tests`.
2. Output per-suite totals (`E2E`, `Integration`, `Unit`, `All`).

If you want to run Robot manually, the core command is:

```bash
python -m robot -d reports/all tests
```

### Parallelising Plaid contract tests

Pabot can split suites across workers:

```bash
pip install robotframework-pabot   # once per environment
pabot --processes 4 --outputdir reports/all_parallel tests
```

Adjust `--processes` to the desired level of parallelism.

---

## Project Layout

```
resources/ui/
  Browser.robot            # Shared browser/context lifecycle keywords
  HomePage.robot           # Home page assertions & navigation
  ProductsPage.robot       # Product catalogue interactions
  ProductDetailsPage.robot # Product detail & add-to-cart actions
  CartPage.robot           # Cart summary validations
  LoginPage.robot          # Login form actions & verifications
  Footer.robot             # Footer subscription workflow

tests/ui/
  automation_exercise.robot  # Suite containing the UI smoke tests
```

The resource files expose keywords that hide selectors and workflow details. The test suite imports those resources, sets up the browser, and defines the individual scenarios.

## Keywords Summary

- **Browser.robot**
  - `Open Browser To Automation Exercise`: launches a Playwright browser (`chromium`) in headed mode, opens a new context and page at the base URL.
  - `Go To Home Page`: navigates to the home URL.
  - `Close Automation Browser`: closes the Playwright browser once the suite finishes.
  - Helper utilities: `Url Should Contain`, `Wait For Url To Contain`, `Scroll Page To Bottom`, `Scroll Element Into View`.

- **HomePage.robot**
  - `Home Page Should Be Visible`, `Open Products Page`, `Open Signup Login Page`, `Scroll To Footer`.

- **ProductsPage.robot**
  - `Products Page Should Be Visible`, `Search For Product`, `Open First Product Details`.

- **ProductDetailsPage.robot**
  - `Add Product To Cart And View Cart`.

- **CartPage.robot**
  - `Cart Should Contain Items` with internal retry helper `Cart Rows Should Exist`.

- **LoginPage.robot**
  - `Attempt Login With Credentials`, `Should See Invalid Login Error`.

- **Footer.robot**
  - `Subscribe With Email`, `Should See Subscription Success`.

## Test Cases

`tests/ui/automation_exercise.robot` defines four smoke scenarios:

1. **Home Navigation And Product Search**  
   Validates home page load, navigation to products, and search results.

2. **Invalid Login Shows Error Banner**  
   Tries to sign in with fake credentials and checks the error message.

3. **Add Product To Cart Displays In Summary**  
   Opens a product detail page, adds it to the cart, and asserts the cart summary shows an entry.

4. **Footer Subscription Confirmation**  
   Scrolls to the footer, subscribes with a random email, and confirms the success banner.

Suite setup/teardown (`Open Browser To Automation Exercise` / `Close Automation Browser`) ensure each run uses a fresh Playwright context.

## Dependencies & Installation

1. Activate the project virtual environment.
2. Install Robot Framework Browser and its prerequisites:

   ```bash
   pip install robotframework-browser
   rfbrowser init   # downloads Playwright browsers (requires npm/node)
   ```

   > `rfbrowser init` needs Node.js/npm on the host machine.

3. Optional: install `robotframework-pabot` if you want parallel execution.

## Running The Suite

### Serial execution

```bash
cd /Users/kristijandimovski/Desktop/RF-FINTECH/rf-fintech
source .venv/bin/activate
python -m robot tests/ui/automation_exercise.robot
```

### Parallel execution with Pabot

```bash
cd /Users/kristijandimovski/Desktop/RF-FINTECH/rf-fintech
source .venv/bin/activate
pip install robotframework-pabot  # once
pabot --processes 4 --outputdir reports/ui_parallel tests/ui
```

The parallel command executes one suite per Playwright browser. Adjust `--processes` to match the number of concurrent workers you want.

### Docker & CI/CD

- **Local container runs**

  ```bash
  docker compose build
  docker compose run --rm robot bash ci/scripts/run-plaid.sh
  docker compose run --rm robot bash ci/scripts/run-ui.sh
  ```

- **GitHub Actions**

  `.github/workflows/tests.yml` builds a cached Playwright-enabled image and runs both suites in parallel matrix jobs. Artifacts (Robot logs/reports) are uploaded per suite. Make sure `PLAID_CLIENT_ID`, `PLAID_SECRET`, and `PLAID_WEBHOOK_URL` are added as repository secrets.

## Notes

- Browsers run **headed** by default. Override by exporting `PLAYWRIGHT_HEADLESS=true` (used automatically in Docker/CI).
- Each test generates fresh data (e.g., subscription email addresses include a random suffix) to avoid clashes between repeated runs.
- The POM resources group selectors so future maintenance only requires touching the relevant page file.

This POM setup plus Robot Browser provide a readable suite that remains easy to extend with additional scenarios.
