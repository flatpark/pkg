#!/usr/bin/env bash
# Update resolver for honk (same contract as FlatPark's resolvers).
#
# Prints the newest upstream version + its amd64 .deb as JSON:
#   { "version": "0.1.0-beta.5", "releaseDate": "YYYY-MM-DD",
#     "sources": [ { "filename": "honk-core.deb", "url": "..." } ] }
# Logs go to stderr.
#
# Pre-releases are followed: upstream marks every release so far as a
# pre-release, so /releases/latest would find nothing. Only version tags count,
# vX.Y.Z and vX.Y.Z-(alpha|beta|rc).N; this skips the rolling `debug*` builds
# and the old v0.0.1.beta.N scheme. The newest is picked by version, not by
# date, so a late patch to an older line cannot win. check-update.sh turns the
# "-" into "~" so a pre-release sorts below its release.
set -euo pipefail

repo="daeuniverse/honk"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }; }
need curl; need jq

rels="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
        "https://api.github.com/repos/$repo/releases?per_page=100")"

# Sort key: [major, minor, patch, stage, n] with stage alpha=0, beta=1, rc=2,
# release=3, so 0.1.0 > 0.1.0-rc.1 > 0.1.0-beta.5.
rel="$(jq -c '
    def key: capture("^v(?<ma>[0-9]+)\\.(?<mi>[0-9]+)\\.(?<pa>[0-9]+)(-(?<st>alpha|beta|rc)\\.(?<n>[0-9]+))?$")
        | [(.ma, .mi, .pa | tonumber),
           ({"alpha": 0, "beta": 1, "rc": 2}[.st // ""] // 3),
           ((.n // "0") | tonumber)];
    [.[] | select(.draft | not) | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+(-(alpha|beta|rc)\\.[0-9]+)?$"))]
    | max_by(.tag_name | key) // empty' <<<"$rels")"
[ -n "$rel" ] || { echo "no honk version tag found" >&2; exit 1; }

tag="$(jq -r '.tag_name' <<<"$rel")"
version="${tag#v}"
date="$(jq -r '.published_at' <<<"$rel" | cut -c1-10)"
# Each release carries .deb/.rpm/.pkg.tar.zst for x86_64 and aarch64 plus the
# tarballs. Take the amd64 .deb exactly: it holds the static musl full build,
# the systemd unit and the example config.
url="$(jq -r --arg n "honk-core-$tag-x86_64.deb" \
        '.assets[] | select(.name == $n) | .browser_download_url' <<<"$rel" | head -n1)"

[ -n "$url" ] || { echo "honk $version has no honk-core-$tag-x86_64.deb (yet?)" >&2; exit 1; }
echo "resolved honk $version ($date): $url" >&2

jq -n --arg v "$version" --arg d "$date" --arg u "$url" \
  '{version:$v, releaseDate:$d, sources:[{filename:"honk-core.deb", url:$u}]}'
