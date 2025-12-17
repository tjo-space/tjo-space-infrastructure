# Always use devbox environment to run commands.
set shell := ["devbox", "run"]
# Load dotenv
set dotenv-load

export SOPS_AGE_KEY_FILE := if os() == "linux" {`echo "$HOME/.config/sops/age/keys.txt"`} else { `echo "$HOME/Library/Application Support/sops/age/keys.txt"` }

mod dns 'dns'
mod media 'media.tjo.space'

import 'secrets.justfile'

encrypt-all: dot-env-encrypt secrets-md-encrypt tofu-state-encrypt ansible-secrets-encrypt
decrypt-all: dot-env-decrypt secrets-md-decrypt tofu-state-decrypt ansible-secrets-decrypt

post-pull: decrypt-all
pre-commit: encrypt-all lint format

default:
  @just --list

lint:
  @tofu fmt -check -recursive .
  @tflint --recursive
  @find . -type f -name "config.alloy*" -exec alloy fmt -t {} \;
  @find . -type f -name "Caddyfile" -exec caddy fmt {} > /dev/null \;
  @find . -type f -name "Caddyfile" -exec caddy validate --config {} \;

format:
  @tofu fmt -recursive .
  @tflint --recursive
  @find . -type f -name "config.alloy*" -exec alloy fmt -w {} \;
  @find . -type f -name "Caddyfile" -exec caddy fmt -w {} \;

dependencies: shared
  ansible-galaxy role install rywillia.ssh-copy-id

shared:
  #!/usr/bin/env bash
  rm -rf shared || true
  mkdir -p shared

  TEMP=$(mktemp -d)
  git clone --depth=1 ssh://git@code.tjo.space/tjo-cloud/infrastructure.git $TEMP
  rsync -a $TEMP/shared/ shared/
  rm -rf $TEMP
