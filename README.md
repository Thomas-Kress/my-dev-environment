# Dev Environment

Isolated Docker-based development environment, kept separate from the host machine. Use it as a long-lived workspace for coding agents and everyday CLI tooling without installing those tools on the host.

## What's included

Built from Ubuntu 24.04 with:

| Tool | Purpose |
|------|---------|
| **Node.js 22 + npm** | JavaScript runtime and package manager |
| **Python 3** | Python runtime (`python3`, `pip`, `venv`) |
| **uv** | Fast Python package manager |
| **Git** | Version control |
| **tini** | Init process (PID 1) for signal forwarding and clean shutdown |
| **Claude Code** | Anthropic coding agent (`claude`) |
| **Codex** | OpenAI coding agent (`codex`) |
| **OpenCode** | Open-source terminal coding agent (`opencode`) |

The container uses **tini** as PID 1 and stays running via `sleep infinity` so you can attach and detach without rebuilding. The working directory inside the container is `/workspace`.

## Build

```bash
docker build -t dev-environment -f dockerfile .
```

## Long-lived workspace

Use this when you want a persistent environment you can leave running and reattach to.

Start a detached container:

```bash
docker run -d --name dev-env -v ${PWD}:/workspace dev-environment
```

- `-d` — run in the background  
- `--name dev-env` — stable name for exec/stop  
- `-v ${PWD}:/workspace` — mount the current host directory into `/workspace`  

Omit the `-v` flag if you want a fully isolated filesystem with no host mount.

### Attach

```bash
docker exec -it dev-env bash
```

Exit the shell with `exit` — the container keeps running.

### Stop and remove

```bash
docker stop dev-env
docker rm dev-env
```

`docker stop` sends SIGTERM to tini (PID 1), which forwards it to the keepalive process and shuts the container down cleanly (default 10s grace period before SIGKILL).

## Short-term workspace

Use this for a one-off session. The container is interactive and is removed automatically when you exit.

```bash
docker run --rm -it -v ${PWD}:/workspace dev-environment bash
```

- `--rm` — delete the container when it exits  
- `-it` — interactive terminal  
- `bash` — overrides `CMD` only; **tini** stays as PID 1 for clean signal handling  

When you type `exit`, the shell and container both go away. Anything not written to the mounted volume is discarded.

Omit `-v` for a fully disposable, isolated session with no host mount.

## Notes

- Claude Code, Codex, and OpenCode need authentication on first use inside the container (browser login and/or API keys).
- Rebuild the image after changing the Dockerfile to pick up new tools or versions.
- Prefer a long-lived workspace if you need to keep agent auth, caches, or in-container state between sessions.
