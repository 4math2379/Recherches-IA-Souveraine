import os

SECRET_KEY = os.environ["SUPERSET_SECRET_KEY"]
SQLALCHEMY_DATABASE_URI = os.environ["SUPERSET_DATABASE_URI"]

# Behind Caddy (TLS terminated at the platform gateway).
ENABLE_PROXY_FIX = True
PREFERRED_URL_SCHEME = "https"

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "DASHBOARD_RBAC": True,
}
