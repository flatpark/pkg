#!/usr/bin/env bash
# The binary reports the packaged upstream version, and a direct-only config
# starts in mock mode (no BPF, no root datapath): parsing, routing compilation,
# DNS and the control plane come up and log "honk-core is running".
set -euo pipefail

deb="$(dpkg-query -W -f='${Version}' honk-core)"
up="${deb%-*}"
honk-core --version | tee /dev/stderr | grep -Fq "v${up//\~/-}"

tmp="$(mktemp -d)"
trap 'kill "$pid" 2>/dev/null || true; wait 2>/dev/null || true; rm -rf "$tmp"' EXIT
cat > "$tmp/config.dae" <<CFG
global {
    data_dir: '$tmp/data'
    nfqueue_enable: false
    preconnect_node_count: 0
    udp_warm_node_count: 0
}
routing {
    fallback: direct
}
CFG
chmod 600 "$tmp/config.dae"

honk-core --config "$tmp/config.dae" --mock-ebpf > "$tmp/log" 2>&1 &
pid=$!
for _ in $(seq 60); do
    if grep -q 'honk-core is running' "$tmp/log"; then exit 0; fi
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.5
done
cat "$tmp/log" >&2
echo "honk-core did not come up in mock mode" >&2
exit 1
