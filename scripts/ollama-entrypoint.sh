#!/bin/sh
set -eu

OLLAMA_HOST=0.0.0.0:11434 ollama serve &
server_pid=$!

cleanup() {
  kill "$server_pid" 2>/dev/null || true
  wait "$server_pid" 2>/dev/null || true
}

trap cleanup TERM INT

until OLLAMA_HOST=127.0.0.1:11434 ollama ps >/dev/null 2>&1; do
  if ! kill -0 "$server_pid" 2>/dev/null; then
    wait "$server_pid"
    exit 1
  fi
  sleep 1
done

OLLAMA_HOST=127.0.0.1:11434 ollama pull "$OLLAMA_MODEL"
wait "$server_pid"
