#!/usr/bin/env bash
# regreet: ReGreet, the GTK 4 greetd greeter, built from rharish101/ReGreet.
# Upstream tags releases without a "v" prefix.
set -euo pipefail
. "$(dirname "$0")/../../scripts/lib.sh"
VERSION="$1" WORK="$2"
"$ROOT/scripts/cargo/fetch-tag.sh" regreet https://github.com/rharish101/ReGreet "$VERSION" "$WORK" "$VERSION"
