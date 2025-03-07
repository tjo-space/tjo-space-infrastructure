#!/bin/bash
set -euo pipefail

pushd "$(mktemp -d)"

echo "=== Installing Dependencies"
DEBIAN_FRONTEND=noninteractive apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y \
  rsync \
  jq \
  podman \
  age

echo "=== Generating Age Key"
mkdir -p /etc/age
age-keygen -o /etc/age/key.txt
