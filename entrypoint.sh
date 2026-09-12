#!/usr/bin/env bash
set -euo pipefail

# Add custom startup logic here (env files, wait-for services, extra tools).
# The script always ends by exec'ing tini so it becomes PID 1, forwards
# signals, and reaps zombie processes. CMD / docker run args are passed through.

exec /usr/bin/tini -- "$@"
