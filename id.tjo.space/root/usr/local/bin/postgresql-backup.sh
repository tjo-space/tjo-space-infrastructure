#!/usr/bin/env bash

[ -z "${POSTGRES_USER}" ] && { echo "=> POSTGRES_USER cannot be empty" && exit 1; }
[ -z "${POSTGRES_PASSWORD}" ] && { echo "=> POSTGRES_PASSWORD cannot be empty" && exit 1; }
[ -z "${GZIP_LEVEL}" ] && { GZIP_LEVEL=6; }

DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"

export PGHOST=${POSTGRES_HOST}
export PGPORT=${POSTGRES_PORT}
export PGUSER=${POSTGRES_USER}
export PGPASSWORD=${POSTGRES_PASSWORD}

DATABASES=${POSTGRES_DATABASE:-${POSTGRES_DB:-$(psql "${POSTGRES_SSL_OPTS}" -t -c "SELECT datname FROM pg_database;")}}

for db in ${DATABASES}; do
  if [[ "$db" != "template1" ]] &&
    [[ "$db" != "template0" ]]; then

    echo "==> Dumping database: $db"

    FILENAME=${BACKUP_DIR}/$DATE.$db.sql

    if pg_dump ${POSTGRESDUMP_OPTS} "${db}" >"${FILENAME}"; then
      if [ -z "${USE_PLAIN_SQL}" ]; then
        echo "==> Compressing $db with LEVEL $GZIP_LEVEL"
        gzip "-$GZIP_LEVEL" -f "$FILENAME"
      fi
    else
      rm -rf "$FILENAME"
    fi
  fi
done
echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
