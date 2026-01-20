#!/usr/bin/env bash
set -euo pipefail

OUTDIR=${1:-./out}
YARA_REPO=${YARA_REPO:-https://github.com/VirusTotal/yara.git}
YARA_TAG=${YARA_TAG:-master}

mkdir -p "$OUTDIR"
tmp=$(mktemp -d)
git clone --depth 1 --branch "$YARA_TAG" "$YARA_REPO" "$tmp/yara"
pushd "$tmp/yara" >/dev/null

sudo apt-get update
sudo apt-get install -y build-essential cmake automake libtool pkg-config python3 python3-pip libssl-dev

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"

mkdir -p "$OUTDIR/bin" "$OUTDIR/lib" "$OUTDIR/rules"
cp src/yara "$OUTDIR/bin/" || true
# try copy libyara
if [ -f src/libyara/.libs/libyara.so ]; then
  cp src/libyara/.libs/libyara.so* "$OUTDIR/lib/" || true
fi

popd >/dev/null
rm -rf "$tmp"
echo "Done: $OUTDIR"