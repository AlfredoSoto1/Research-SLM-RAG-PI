#!/usr/bin/env bash
set -euo pipefail

database_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
schema_file="$database_dir/schema.sql"

: "${DATABASE_URL:?DATABASE_URL must be set to the development database}"

if ! command -v psql >/dev/null 2>&1; then
    printf 'psql is required to reset the database.\n' >&2
    exit 1
fi

if [[ ! -f "$schema_file" ]]; then
    printf 'Schema file not found: %s\n' "$schema_file" >&2
    exit 1
fi

printf 'Resetting the database schema using %s\n' "$schema_file"
psql "$DATABASE_URL" \
    --set=ON_ERROR_STOP=1 \
    --single-transaction \
    --command='DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;' \
    --file="$schema_file"
