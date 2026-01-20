#!/usr/bin/env bash
set -euo pipefail
OUTDIR=${1:-./out}
mkdir -p "$OUTDIR"
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker run --rm --platform linux/arm64 -v "$PWD":/work -w /work ubuntu:22.04 /bin/bash -lc "\
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake automake libtool pkg-config git python3 python3-pip libssl-dev && \
git clone --depth 1 https://github.com/VirusTotal/yara.git /work/yara && \
mkdir -p /work/yara/build && cd /work/yara/build && \
cmake .. -DCMAKE_BUILD_TYPE=Release && make -j\$(nproc) && \
mkdir -p /work/$OUTDIR/bin /work/$OUTDIR/lib && cp src/yara /work/$OUTDIR/bin/ || true \
"
echo "ARM build finished; check $OUTDIR"