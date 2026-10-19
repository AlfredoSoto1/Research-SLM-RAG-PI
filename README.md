# slm-rag-pi

## Development environment

Open this repository in a Dev Container. Dev Container Features install Node.js 24, the latest TypeScript 7.x compiler, and Git. The Dockerfile installs the C/C++ build and Raspberry Pi hardware libraries plus PostgreSQL client tools. PostgreSQL 17 with pgvector runs as a Compose service.

- The workspace is mounted at `/workspace`.
- Frontend work lives in `/workspace/frontend`; C/C++ firmware work lives in `/workspace/firmware`.
- On container creation, `.devcontainer/post-create.sh` creates `frontend/node_modules` and `frontend/.next` and sets them writable by the active container user.
- Add Next.js and other app dependencies to the frontend project when you initialize it; Node.js and npm are provided by the Node Feature.
- Run a frontend on `0.0.0.0:3000` to reach it at `http://localhost:43000`.
- Port `18080` is forwarded for a future service listening on `0.0.0.0:8080`.
- PostgreSQL is available to the workspace at `rag-db:5432` and to host database tools at `localhost:15432`.
- C and C++ are compiled for the development computer's architecture in the regular Dev Container.
- The connection string is available as `DATABASE_URL`.
- `psql` is installed in the workspace. Connect with `psql "$DATABASE_URL"` and check the extension with `SELECT extversion FROM pg_extension WHERE extname = 'vector';`.

The database starts without application schema. The schema is in `database/schema.sql`; run `./database/reset-db.sh` from the workspace when you want to drop and recreate it. The Dev Container's post-start hook grants the reset script execute permission but does not run it. The reset script also enables `pgvector`.

The database credentials in `.env` are for local development. The Compose file loads that file into both services.

## Raspberry Pi 5

Use a 64-bit operating system on the Pi 5. The Compose file does not pin a platform, so Docker selects native images on the development computer and ARM64 images on the Pi. The Dev Container base image, Node Feature, and pgvector image support ARM64.

The development Compose limits are sized for a regular computer (workspace up to 4 GiB, database up to 1 GiB), not for a 4 GiB production Pi. Before deploying an application to the Pi, build or publish its production image for `linux/arm64` (or as a multi-platform image). This repository currently defines the development workspace and database, not a production application image; size production memory limits for the actual workload and the Pi's RAM.

The regular Dev Container builds C/C++ for the development computer's architecture. A container running on the computer cannot directly access GPIO pins on a separate Pi. For native ARM64 builds and direct hardware access, connect to the Pi with Remote SSH, then start the Pi config from the repository on the Pi with the Dev Container CLI:

```sh
devcontainer up --workspace-folder /path/to/slm-rag-pi --config /path/to/slm-rag-pi/.devcontainer/devcontainer.pi.json
```

Then use VS Code's **Dev Containers: Attach to Running Container** command in the Remote SSH session. The Pi Compose override passes `/dev/gpiochip0` into the workspace and runs the development container as root; it does not enable broad privileged mode. Raspberry Pi OS must expose the GPIO device. The host interfaces must be enabled before adding the optional I2C, SPI, or UART mappings in `.devcontainer/docker-compose.pi.yml`. The image includes `libgpiod-dev`, `gpiod`, and I2C development tools. Raspberry Pi's current GPIO guidance uses the Linux GPIO character device API (`/dev/gpiochipX`); on Pi 5 the header GPIO controller appears as `gpiochip0` on current Raspberry Pi OS. Older OS/kernel versions may use a different chip number. See the [Raspberry Pi GPIO guidance](https://pip-assets.raspberrypi.com/categories/685-app-notes-guides-whitepapers/documents/RP-006553-WP/A-history-of-GPIO-usage-on-Raspberry-Pi-devices-and-current-best-practices).

## Firmware

The C++17 firmware starter lives in `firmware/`. Configure and build it from the repository root with CMake:

```sh
cmake -S firmware -B build/firmware
cmake --build build/firmware
```

Run `build/firmware/slm-rag-pi-firmware` to print the runtime status (with a `.exe` suffix on Windows). The executable also accepts `--help` and `--version`. Multi-configuration CMake generators place the executable under a configuration subdirectory such as `Debug/` or `Release/`.
