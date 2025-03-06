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

echo "=== Installing Dependencies"
DEBIAN_FRONTEND=noninteractive apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y \
  rsync \
  jq \
  podman

echo "=== Configure Firewall"
ufw allow 22/tcp  # SSH
ufw allow 443/tcp # HTTPS
ufw allow 636/tcp # LDAPS
ufw --force enable

echo "== Configure Metadata"
DOMAIN_NAME=$(jq -r ".domain" /etc/tjo.space/meta.json)

echo "=== Copy Configuration Files"
rsync -av id.tjo.space/containers/ /etc/containers/systemd/
rsync -av id.tjo.space/configs/ /etc/

echo "=== Setup Caddy"
cat <<EOF >/etc/caddy/env
DOMAIN_NAME=${DOMAIN_NAME}
EOF

systemctl enable --now caddy
