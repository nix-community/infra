#!/usr/bin/env bash
# Run this command to reproduce CI
set -euo pipefail
cd "$(dirname "$0")"
nix-build --no-out-link
