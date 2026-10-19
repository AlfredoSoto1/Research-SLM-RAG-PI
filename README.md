# slm-rag-pi

## Docker Compose stack

The root `docker-compose.yaml` starts two services:

- `rag-db`: PostgreSQL 17 with pgvector. A new database volume is initialized from `database/schema.sql`.
- `ollama`: Ollama's local model API. On first start it downloads the model selected by `OLLAMA_MODEL`.

Start both services from the repository root:

```sh
docker compose up -d
docker compose ps
docker compose logs -f ollama
```

The first Ollama start downloads about 1 GB for the default Q4 model. Its API is available at `http://localhost:11434`; PostgreSQL is available from the host at `localhost:15432`. Containers on this Compose network can connect to PostgreSQL at `rag-db:5432` and Ollama at `ollama:11434`.

The model API uses Ollama's `/api/chat` endpoint. For example:

```sh
curl http://localhost:11434/api/chat \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen2.5:1.5b-instruct-q4_K_M","messages":[{"role":"user","content":"Hello"}]}'
```

Inspect the downloaded and currently loaded model with:

```sh
docker compose exec ollama ollama list
docker compose exec ollama ollama ps
```

## Model quantization and memory

The default is `qwen2.5:1.5b-instruct-q4_K_M` (Q4_K_M weights, about 986 MB). Ollama supports model tags with other quantizations; change `OLLAMA_MODEL` in `.env` to the desired tag and restart the `ollama` service. The selected model is pulled automatically, and downloaded model files persist in the `ollama-models` volume.

The `.env` file controls these limits:

| Setting | Default | Controls |
| --- | --- | --- |
| `OLLAMA_MODEL` | `qwen2.5:1.5b-instruct-q4_K_M` | Model and weight quantization |
| `OLLAMA_MEM_LIMIT` | `2500m` | Hard container RAM limit |
| `OLLAMA_CONTEXT_LENGTH` | `2048` | Context window; larger values need more memory |
| `OLLAMA_NUM_PARALLEL` | `1` | Concurrent requests per model |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Models held in memory at once |
| `OLLAMA_KEEP_ALIVE` | `5m` | Time a model stays loaded after a request |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | KV cache precision; use `f16` for higher precision or `q4_0` to reduce cache RAM further |

The Ollama container also enables Flash Attention and disables cloud features. After editing `.env`, apply changes with `docker compose up -d`. Increase `OLLAMA_MEM_LIMIT` when selecting a model with larger weights or a longer context. These defaults target CPU inference on a memory-constrained Raspberry Pi; GPU passthrough is not configured.

## Database

The connection string for host tools is set in `.env` as `DATABASE_URL`. `psql` can connect with:

```sh
psql "$DATABASE_URL"
```

For an application container on the Compose network, use the `rag-db` hostname and port `5432` instead of `localhost:15432`.

The database schema is initialized automatically when Compose creates a new data volume. For an existing database, `database/reset-db.sh` drops and recreates the `public` schema; it is destructive. Check the Compose `.env` database settings before running it. From a host Bash shell, the script starts `rag-db` if needed and runs `psql` through Docker Compose, so `psql` does not need to be installed on the host and you do not need to open an interactive container shell.

## Firmware

The C++17 firmware starter lives in `firmware/`. Configure and build it from the repository root with CMake:

```sh
cmake -S firmware -B build/firmware
cmake --build build/firmware
```

Run `build/firmware/slm-rag-pi-firmware` to print the runtime status (with a `.exe` suffix on Windows). The executable also accepts `--help` and `--version`. Multi-configuration CMake generators place the executable under a configuration subdirectory such as `Debug/` or `Release/`.
