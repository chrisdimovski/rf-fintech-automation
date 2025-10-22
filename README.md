# rf-fintech (Plaid Sandbox tests)
- Set env vars (Sandbox keys) before running:
  - PLAID_CLIENT_ID
  - PLAID_SECRET
  - (optional) PLAID_WEBHOOK_URL
- Install deps: `pip install -r requirements.txt`
- Run unit-like contracts: `robot -d reports/unit tests/unit`
- Run integration: `robot -d reports/integration tests/integration`
- Run E2E: `robot -d reports/e2e tests/e2e`
