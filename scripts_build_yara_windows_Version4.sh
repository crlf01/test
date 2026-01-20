#!/usr/bin/env bash
# Intended to run inside MSYS2 MINGW64 shell on GitHub Actions windows runner.
set -euo pipefail
OUTDIR=${1:-./out}

git clone --depth 1 https://github.com/VirusTotal/yara.git
# build x64
mkdir -p yara/build_x64 && cd yara/build_x64
export CFLAGS="-D_WIN32_WINNT=0x0502 -static-libgcc -static-libstdc++"
cmake -G "MinGW Makefiles" .. -DCMAKE_BUILD_TYPE=Release
mingw32-make -j$(nproc)
mkdir -p "$OUTDIR/x64/bin"
cp src/yara.exe "$OUTDIR/x64/bin/" || true

# build x86
cd ../..
mkdir -p yara/build_x86 && cd yara/build_x86
export CFLAGS="-D_WIN32_WINNT=0x0502 -m32 -static-libgcc -static-libstdc++"
cmake -G "MinGW Makefiles" .. -DCMAKE_BUILD_TYPE=Release
mingw32-make -j$(nproc)
mkdir -p "$OUTDIR/x86/bin"
cp src/yara.exe "$OUTDIR/x86/bin/" || true

echo "Windows builds done: $OUTDIR"