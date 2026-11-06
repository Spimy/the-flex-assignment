FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm

RUN grep -rl 'dl.yarnpkg.com' /etc/apt/sources.list.d | xargs -r rm -f \
    && apt-get update \
    && apt-get install -y --no-install-recommends lsof postgresql-client redis-tools \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv