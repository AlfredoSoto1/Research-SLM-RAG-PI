# Repository Guidelines

## Project Structure & Module Organization

- `frontend/` is for the TypeScript client and future Next.js app. It has no package manifest yet.
- `firmware/` is for Raspberry Pi C/C++ code. The intended style is Google-based, with two-space indentation and a 100-column limit.
- `database/schema.sql` defines the database schema; `database/reset-db.sh` applies it to the development database.
- `.devcontainer/` contains the Compose services, image build, lifecycle scripts, and two configurations: the regular development computer setup and the Pi hardware setup.

## Build, Test, and Development

- In VS Code, open the repository and choose **Dev Containers: Reopen in Container** for regular development.
- For GPIO access on a Raspberry Pi over Remote SSH, follow the Pi workflow in `README.md` and use `.devcontainer/devcontainer.pi.json`.
- Run `./database/reset-db.sh` from the workspace to drop and recreate the development schema. This is destructive; confirm `DATABASE_URL` points to the intended development database first.
- Build the firmware from the repository root with `cmake -S firmware -B build/firmware && cmake --build build/firmware`.

## Coding Style & Naming

- Use Google-style C/C++ formatting with two-space indentation and a 100-column limit; keep active `clang-format` rules in `firmware/.clang-format` (for example, `clang-format -i firmware/src/main.cpp`).
- Keep frontend formatting and lint rules in the frontend project configuration when it is created; the container provides ESLint and Prettier editor extensions.
- Use descriptive names and keep source files with their corresponding frontend, firmware, or database component.

## Testing Guidelines

No test framework or test files are present yet. Add tests with the relevant application or firmware module, provide a repeatable test command, and update this guide when choosing the framework. Do not report unrun checks as passing.

## Commits & Pull Requests

The repository has no commit history to establish a convention. Use short imperative subjects with a type prefix, such as `feat: add GPIO sensor reader` or `docs: explain database reset`. Pull requests should describe the change, list checks actually run, link related issues, and include screenshots for visible frontend changes.

## Security & Configuration

Compose loads `.env` for local development. Keep its values development-only and never replace them with production credentials. The database reset script drops the `public` schema, so use it only with the intended development database.
