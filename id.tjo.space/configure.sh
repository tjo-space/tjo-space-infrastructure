#!/bin/bash
set -euo pipefail

SERVICE_DIR="/root/service"
mkdir -p ${SERVICE_DIR}
cd ${SERVICE_DIR}

echo "== Fetch Source Code (from git)"
# Clone if not yet cloned
if [ ! -d .git ]; then
  git clone \
    --depth 1 \
    --no-checkout \
    --filter=tree:0 \
    https://github.com/tjo-space/tjo-space-infrastructure.git .
  git sparse-checkout set --no-cone /id.tjo.space
  git checkout
else
  git fetch --depth=1
  git reset --hard origin/main
fi

echo "=== Copy Configuration Files"
rsync -a id.tjo.space/root/ /
systemctl daemon-reload

echo "=== Prepare srv directories"
mkdir -p /srv/authentik/{media,certs,custom-templates}
chown -R 1200:1200 /srv/authentik

mkdir -p /srv/postgresql/data

echo "=== Read Secrets"
age -d -i /etc/age/key.txt id.tjo.space/secrets.env.encrypted >id.tjo.space/secrets.env
set -a && source id.tjo.space/secrets.env && set +a

echo "=== Prepare Configurations"
mkdir -p /etc/postgresql
cat <<EOF >/etc/postgresql/secrets.env
POSTGRES_PASSWORD=${POSTGRESQL_PASSWORD}
EOF
mkdir -p /etc/authentik
cat <<EOF >/etc/authentik/secrets.env
AUTHENTIK_SECRET_KEY=${AUTHENTIK_SECRET_KEY}
AUTHENTIK_EMAIL__PASSWORD=${AUTHENTIK_EMAIL__PASSWORD}
AUTHENTIK_POSTGRESQL__PASSWORD=${POSTGRESQL_PASSWORD}
EOF

echo "=== Setup Caddy"
systemctl restart caddy

echo "=== Setup Postgresql"
systemctl restart postgresql

echo "=== Setup Valkey"
systemctl restart valkey

echo "=== Setup Authentik Server"

systemctl restart authentik-server

echo "=== Setup Authentik Worker"
systemctl restart authentik-worker
