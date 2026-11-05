#!/usr/bin/env bash
# sysc-greet: built from the upstream tag v<version>. Go modules are vendored
# here (network) so the package build itself runs offline.
set -euo pipefail
. "$(dirname "$0")/../../scripts/lib.sh"
VERSION="$1" WORK="$2"
TREE="sysc-greet-$VERSION"

cd "$WORK"
rm -rf "$TREE" "sysc-greet_${VERSION}.orig.tar.gz"
log "clone sysc-greet v$VERSION"
git clone -q --depth 1 --branch "v$VERSION" https://github.com/Nomadcxx/sysc-greet "$TREE"
rm -rf "$TREE/.git"

(
    cd "$TREE"
    export GOTOOLCHAIN=local GOFLAGS=-modcacherw GOPATH="$WORK/gopath"
    go mod vendor
)
rm -rf "$WORK/gopath"

tar --create --gzip --owner=0 --group=0 --numeric-owner \
    -f "sysc-greet_${VERSION}.orig.tar.gz" "$TREE"
overlay_debian sysc-greet "$TREE"
