#!/usr/bin/env bash
set -euo pipefail

database_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd -- "$database_dir/.." && pwd)"
schema_file="$database_dir/schema.sql"
compose_file="$repository_dir/docker-compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
    printf 'Docker with the Compose plugin is required to reset the database.\n' >&2
    exit 1
fi

if [[ ! -f "$schema_file" ]]; then
    printf 'Schema file not found: %s\n' "$schema_file" >&2
    exit 1
fi

if [[ ! -f "$compose_file" ]]; then
    printf 'Compose file not found: %s\n' "$compose_file" >&2
    exit 1
fi

compose=(docker compose --project-directory "$repository_dir" --file "$compose_file")

printf 'Starting the Compose database service if needed.\n'
"${compose[@]}" up -d rag-db

printf 'Waiting for PostgreSQL to become ready.\n'
ready=false
for attempt in {1..60}; do
    if "${compose[@]}" exec -T rag-db sh -c \
        'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' >/dev/null 2>&1; then
        ready=true
        break
    fi
    sleep 1
done

if [[ "$ready" != true ]]; then
    printf 'PostgreSQL did not become ready within 60 seconds. Check: docker compose logs rag-db\n' >&2
    exit 1
fi

printf 'Resetting the public schema using %s\n' "$schema_file"
"${compose[@]}" exec -T rag-db sh -c \
    'exec psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" --set=ON_ERROR_STOP=1 --single-transaction --command="DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;" --file=/docker-entrypoint-initdb.d/001-schema.sql'
