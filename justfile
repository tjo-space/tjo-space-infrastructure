# Always use devbox environment to run commands.
set shell := ["devbox", "run"]
# Load dotenv
set dotenv-load

default:
  @just --list

dot-env-encrypt:
  sops \
    --encrypt \
    --input-type=dotenv \
    --output-type=dotenv \
    .env > .env.encrypted

dot-env-decrypt:
  sops \
    --decrypt \
    --input-type=dotenv \
    --output-type=dotenv \
    .env.encrypted > .env

tofu-state-encrypt:
  #!/bin/bash
  for file in $(find -name tofu.tfstate -o -name terraform.tfstate)
  do
    echo "Encrypting $file"
    sops \
      --encrypt \
      --input-type=json \
      --output-type=json \
      $file > ${file}.encrypted
  done

tofu-state-decrypt:
  #!/bin/bash
  for file in $(find -name tofu.tfstate.encrypted -o -name terraform.tfstate.encrypted)
  do
    echo "Decrypting $file"
    sops \
      --decrypt \
      --input-type=json \
      --output-type=json \
      $file > ${file%.encrypted}
  done

lint:
  @tofu fmt -check -recursive .
  @tflint --recursive

format:
  @tofu fmt -recursive .
  @tflint --recursive

apply:
  #!/usr/bin/env sh
  cd {{source_directory()}}/terraform
  tofu init
  tofu apply

destroy:
  #!/usr/bin/env sh
  cd {{source_directory()}}/terraform
  tofu  destroy

outputs:
  #!/usr/bin/env sh
  cd {{source_directory()}}/terraform
  tofu output

configure:
  #!/usr/bin/env sh
  set -eou pipefail

  pushd {{source_directory()}}/terraform > /dev/null
  IPV4=$(tofu output -json | jq -r '.ipv4')
  popd > /dev/null

  echo "= Provisioning id.tjo.space"
  cat install.sh | ssh ubuntu@${IPV4} 'sudo bash -s'
