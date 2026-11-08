#!/usr/bin/env bash
# Read-only checks for a new n8n deployment on a prepared Linux server.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() { echo "Error: $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || fail "Install Docker using your distribution's instructions first."
docker compose version >/dev/null 2>&1 || fail "Install the Docker Compose plugin first."
docker info >/dev/null 2>&1 || fail "Docker daemon is unavailable or access is denied. Check the daemon and permissions; if required, rerun with sudo."
[ -f .env ] || fail "Create .env from .env.example and fill in your deployment settings first."

# Let Compose parse .env; never execute it as shell code or print its secrets.
docker compose config --quiet

if command -v ss >/dev/null 2>&1; then
    listeners="$(ss -H -ltn '( sport = :80 or sport = :443 )')"
    [ -z "$listeners" ] || fail "TCP port 80 or 443 is occupied. Inspect with sudo ss -ltnp. This stack needs both ports; an existing proxy requires a separate integration."
else
    echo "Warning: ss is unavailable. Manually confirm that TCP ports 80 and 443 are free."
fi

echo "Docker access and Compose configuration checks passed."
echo "Confirm DNS and inbound TCP 80/443 in the host/provider firewall (and router if applicable)."
echo "No packages, firewall rules, timezone settings, or containers were changed."
echo "When ready, start: docker compose up -d"
