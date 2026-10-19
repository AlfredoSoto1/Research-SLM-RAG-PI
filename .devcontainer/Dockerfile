FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang-format \
        cmake \
        gdb \
        gpiod \
        i2c-tools \
        libgpiod-dev \
        libi2c-dev \
        ninja-build \
        pkg-config \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
USER vscode
