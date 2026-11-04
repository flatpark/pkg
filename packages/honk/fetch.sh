#!/usr/bin/env bash
# honk: the official amd64 .deb (static musl full build), unpacked and
# repackaged unmodified. Only its data is used; debian/ replaces its control
# files and maintainer scripts.
set -euo pipefail
. "$(dirname "$0")/../../scripts/lib.sh"
VERSION="$1" WORK="$2"
TREE="$WORK/honk-$VERSION"

# Not straight into $WORK: build-in-container.sh releases every $WORK/*.deb.
mkdir -p "$WORK/upstream"
cd "$WORK/upstream"
fetch_pinned honk "honk-core_${VERSION}.deb"
rm -rf "$TREE"
# The .deb's data is laid out as the install root (./usr, ./etc).
dpkg-deb -x "honk-core_${VERSION}.deb" "$TREE"
# Upstream's doc files are regenerated from debian/.
rm -rf "$TREE/usr/share/doc"
overlay_debian honk "$TREE"
