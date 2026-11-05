#!/usr/bin/env bash
# Newest stable release tag of Nomadcxx/sysc-greet, as {"version": "..."}.
set -euo pipefail
v="$(git ls-remote --tags --refs https://github.com/Nomadcxx/sysc-greet 'refs/tags/v*' \
    | sed 's|.*/v||' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)"
[ -n "$v" ] || { echo "no release tag found" >&2; exit 1; }
jq -n --arg v "$v" '{version: $v}'
