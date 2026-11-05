#!/usr/bin/env bash
# No display in the build container: check that the binary loads (every
# DT_NEEDED resolves) and that clap answers before GTK starts.
set -euo pipefail
if ldd /usr/bin/regreet | grep 'not found'; then exit 1; fi
regreet --help >/dev/null
test -f /usr/lib/tmpfiles.d/regreet.conf
