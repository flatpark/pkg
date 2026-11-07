#!/usr/bin/env bash
# Newest release tag of rharish101/ReGreet (bare x.y.z tags), as {"version": "..."}.
set -euo pipefail
v="$(git ls-remote --tags --refs https://github.com/rharish101/ReGreet 'refs/tags/*' \
    | sed 's|.*/||' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)"
[ -n "$v" ] || { echo "no release tag found" >&2; exit 1; }
jq -n --arg v "$v" '{version: $v}'
