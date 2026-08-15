#!/usr/bin/env bash
# Release helper for app-wiz4rd — builds BOTH release artifacts for a GitHub
# release:
#
#   1. release/app-wiz4rd-$VER.tar.gz          SOURCE tarball (AUR makepkg).
#      Deterministic: archiving HEAD^{tree} (NOT HEAD) skips the commit-id
#      pax comment, and aur/ + scripts/ + .github/ are excluded with
#      --mtime pinned — so the sha256 only changes when the shipped source
#      actually changes.
#   2. release/app-wiz4rd-$VER-$ARCH.tar.gz    ZERO-INSTALL tarball — ships the
#      prebuilt static TUI, so extracting and running ./app-wiz4rd needs no
#      Go, no AUR helper, no build step.
#
# Usage: ./scripts/release.sh [version]
#   version defaults to pkgver from aur/PKGBUILD.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

VER="${1:-$(grep -m1 '^pkgver=' aur/PKGBUILD | cut -d= -f2)}"
ARCH="${ARCH:-x86_64}"
MTIME="2026-08-14 12:00:00 UTC"   # pinned — keeps the source tarball hash stable
OUT="release"
mkdir -p "$OUT"

STAGE="$(mktemp -d /tmp/app-wiz4rd-release.XXXXXX)"
trap 'rm -rf "$STAGE"' EXIT

# 1. Static TUI binary — the zero-install artifact ships it prebuilt.
echo "==> Building static TUI..."
( cd dialog && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o syntropia-apps-tui . )

# 2. Source tarball (AUR). Only tracked files; aur/ and scripts/ are excluded.
echo "==> Building source tarball (AUR)..."
git archive --format=tar.gz --prefix="app-wiz4rd-$VER/" --mtime="$MTIME" \
    -o "$OUT/app-wiz4rd-$VER.tar.gz" "HEAD^{tree}" -- . ':(exclude)aur' ':(exclude)scripts' ':(exclude).github'

# 3. Zero-install tarball: runtime files + prebuilt binary, nothing to build.
echo "==> Building zero-install tarball..."
STAGEDIR="$STAGE/app-wiz4rd-$VER"
mkdir -p "$STAGEDIR/dialog"
cp app-wiz4rd apps.list syntropia-apps.desktop "$STAGEDIR/"
cp dialog/syntropia-apps-tui "$STAGEDIR/dialog/"
cp LICENSE "$STAGEDIR/LICENSE"
cat > "$STAGEDIR/README.md" <<EOF
# app-wiz4rd $VER — zero-install

Extract and run:

    ./app-wiz4rd

The TUI is a prebuilt static binary — no Go, no AUR helper, no build step.
It installs your picks with paru (bootstraps paru itself if missing). See
the full README at https://github.com/r4-ndm/app-wiz4rd
EOF
tar -czf "$OUT/app-wiz4rd-$VER-$ARCH.tar.gz" \
    --sort=name --numeric-owner --owner=0 --group=0 -C "$STAGE" "app-wiz4rd-$VER"

# Build artifact — keep the tree clean (gitignored anyway).
rm -f dialog/syntropia-apps-tui

echo
echo "Artifacts in $OUT/:"
ls -la "$OUT"
echo
echo "Pin these sha256sums (source -> aur/PKGBUILD + iso/build.sh):"
sha256sum "$OUT/app-wiz4rd-$VER.tar.gz" "$OUT/app-wiz4rd-$VER-$ARCH.tar.gz"
