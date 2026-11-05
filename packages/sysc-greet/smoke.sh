#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../../scripts/lib.sh"
sysc-greet --version | grep -qx "sysc-greet v$(upstream_version sysc-greet)"
# Runs as greetd's _greetd: no account of its own, directories from tmpfiles.
if getent passwd greeter >/dev/null; then echo "unexpected greeter account" >&2; exit 1; fi
test "$(stat -c %U /var/lib/greetd/.cache)" = _greetd
test "$(stat -c %U /var/cache/sysc-greet)" = _greetd
# Configs must point at the packaged binary and _greetd's home.
if grep -l '/usr/local\|/var/lib/greeter' /etc/greetd/kitty.conf /etc/greetd/*-greeter-config*; then exit 1; fi
grep -q 'HOME=/var/lib/greetd' /etc/greetd/sway-greeter-config
grep -q '"_greetd"' /usr/share/polkit-1/rules.d/85-sysc-greet.rules
test -d /usr/share/sysc-greet/ascii_configs
