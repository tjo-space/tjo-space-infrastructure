#!/bin/bash
set -euo pipefail

echo "=== Reading Configuration"
set -a && source /etc/postgresql/postgresql.env && set +a

echo "== Stopping Authentik..."
systemctl stop authentik-server authentik-worker

echo "== Dropping and Recreating Database..."
podman exec systemd-postgresql dropdb --username="${POSTGRES_USER}" --force --if-exists "${POSTGRES_DB}"
podman exec systemd-postgresql createdb --username="${POSTGRES_USER}" "${POSTGRES_DB}"

echo "== Restoring Database..."
cat /dev/stdin | podman exec -i systemd-postgresql pg_restore \
  --username="${POSTGRES_USER}" \
  --dbname="${POSTGRES_DB}"

echo "== Starting Authentik..."
systemctl start authentik-server authentik-worker
