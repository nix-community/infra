#!/usr/bin/env bash
# Run this command to reproduce CI
set -euo pipefail

cd "$(dirname "$0")"
out=$(nix-build nix -A nix-build-uncached)

"$out/bin/nix-build-uncached"
