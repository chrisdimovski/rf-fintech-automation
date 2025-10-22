"""Test runner warning filters for Plaid sandbox."""

import warnings

# Hide noisy sandbox SSL warning emitted when urllib3 loads with LibreSSL.
warnings.filterwarnings(
    "ignore",
    message="urllib3 v2 only supports OpenSSL 1.1.1+",
    category=Warning,
)

try:
    import urllib3  # noqa: E402
except Exception:  # pragma: no cover
    pass
else:
    warnings.filterwarnings(
        "ignore",
        category=urllib3.exceptions.InsecureRequestWarning,
    )
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
