#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../../scripts/lib.sh"
sysc-greet --version | grep -qx "sysc-greet v$(upstream_version sysc-greet)"
getent passwd greeter >/dev/null
# The greeter configs must point at the packaged binary, not /usr/local.
if grep -l /usr/local /etc/greetd/kitty.conf /etc/greetd/*-greeter-config*; then exit 1; fi
test -d /usr/share/sysc-greet/ascii_configs
test -f /usr/share/polkit-1/rules.d/85-sysc-greet.rules
