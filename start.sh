#!/bin/bash
set -eu

RUNNER_DIR="${RUNNER_DIR:-/home/runner/actions-runner}"
RUNNER_USER="${RUNNER_USER:-runner}"

echo "Starting GitHub Actions Runner..."

exec su "$RUNNER_USER" -c "$RUNNER_DIR/run.sh"
