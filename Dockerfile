FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PATH="/root/.local/bin:/usr/local/bin:${PATH}"

# System packages: git, Python, tini (PID 1), build/runtime deps for installers
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        python3 \
        python3-pip \
        python3-venv \
        tini \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 LTS + npm (required by Codex; useful for general JS work)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Claude Code (native installer)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Codex CLI
RUN npm install -g @openai/codex

# OpenCode
RUN curl -fsSL https://opencode.ai/install | OPENCODE_INSTALL_DIR=/root/.local/bin bash

# Smoke-check that every required tool is on PATH
RUN node --version \
    && npm --version \
    && python3 --version \
    && uv --version \
    && claude --version \
    && codex --version \
    && opencode --version \
    && git --version

# Set the working directory for the container
WORKDIR /workspace

# tini as PID 1: forwards signals and reaps zombies for clean shutdown
ENTRYPOINT ["/usr/bin/tini", "--"]

# Keep the container running so it can be used as a long-lived
# development environment (attach with: docker exec -it <name> bash)
CMD ["sleep", "infinity"]
