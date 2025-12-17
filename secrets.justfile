export SHA256SUM := if os() == "linux" {`echo "sha256sum"`} else { `echo "shasum --algorithm 256"` }

_encrypt path:
  #!/usr/bin/env bash
  file="{{path}}"

  echo "Encrypting ${file}"
  if cat ${file}.sha256sum | $SHA256SUM --check --status && ! [ -n "$FORCE_ENCRYPTION" ]
  then
    echo " - matches existing hash, skipping"
  else
    cat $file | gzip --stdout | age --encrypt -R {{source_directory()}}/age.keys > ${file}.encrypted
    $SHA256SUM $file > ${file}.sha256sum
  fi

_decrypt path:
  #!/usr/bin/env bash
  echo "Decrypting {{path}}"
  cat {{path}}.encrypted | age --decrypt -i "${SOPS_AGE_KEY_FILE}" | gzip --decompress --stdout > {{path}}

dot-env-encrypt:
  @just _encrypt .env

dot-env-decrypt:
  @just _decrypt .env

secrets-md-encrypt:
  @just _encrypt SECRETS.md

secrets-md-decrypt:
  @just _decrypt SECRETS.md

tofu-state-encrypt:
  #!/usr/bin/env bash
  for file in $(find . -name tofu.tfstate -o -name terraform.tfstate)
  do
    just _encrypt $file
  done

[confirm('Are you sure? This will overwrite your local state files! Ireversable operation!')]
tofu-state-decrypt:
  #!/usr/bin/env bash
  for file in $(find . -name tofu.tfstate.encrypted -o -name terraform.tfstate.encrypted)
  do
    just _decrypt ${file%.encrypted}
  done

ansible-secrets-encrypt:
  #!/usr/bin/env bash
  for file in $(find . -name vars.secrets.yaml -o -name "vars.*.secrets.yaml")
  do
    just _encrypt $file
  done

ansible-secrets-decrypt:
  #!/usr/bin/env bash
  for file in $(find . -name vars.secrets.yaml.encrypted -o -name "vars.*.secrets.yaml")
  do
    just _decrypt ${file%.encrypted}
  done
