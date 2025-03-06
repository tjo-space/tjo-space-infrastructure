#!/bin/bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "$0 is being run as root. Please run as a regular user." 1>&2
  exit 2
fi

##
echo "== Fetch Source Code (from git)"
cd "$HOME/service"
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

function provision() {
  ##
  echo "=== Installing Dependencies"
  apt update -y
  apt install -y \
    git \
    podman

  ##
  echo "=== Configure Firewall"
  ufw allow 22/tcp  # SSH
  ufw allow 443/tcp # HTTPS
  ufw allow 636/tcp # LDAPS
  ufw enable
}

echo "=== Provision the System (as root)"
sudo -u root bash -c "$(declare -f provision); provision"
