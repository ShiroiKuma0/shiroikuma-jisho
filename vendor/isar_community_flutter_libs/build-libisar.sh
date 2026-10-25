#!/bin/bash
# Rebuild the Android libisar.so binaries in this vendored package from
# isar-community 3.3.2 with isar-iter-between-stop.patch applied.
#
# Why: upstream's Cursor::iter_between never stops at the upper bound once
# a where clause has matched — the closure returns Ok(true) ("continue")
# for every key past the bound, so the walk runs to the end of the index.
# Results stay correct, but a dictionary lookup that hits reads the whole
# rest of a multi-hundred-MB index: seconds from flash on the phone.
#
# Usage: vendor/isar_community_flutter_libs/build-libisar.sh [workdir]
# Needs: git, rustup/cargo, Android NDK 25.1 under ~/Android/Sdk/ndk.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${1:-$(mktemp -d)}
NDK=${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/25.1.8937393}
BIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin

if [ ! -d "$WORK/isar-community" ]; then
  git clone --depth 1 --branch 3.3.2 \
    https://github.com/isar-community/isar-community.git "$WORK/isar-community"
  git -C "$WORK/isar-community" apply "$HERE/isar-iter-between-stop.patch"
fi

export ISAR_VERSION=3.3.2 PATH="$BIN:$PATH"
cd "$WORK/isar-community/packages/isar_core_ffi"

# rust target | NDK clang prefix | jniLibs ABI directory
while read -r target clang abi; do
  rustup target add "$target" >/dev/null
  var=$(echo "$target" | tr 'a-z-' 'A-Z_')
  low=$(echo "$target" | tr '-' '_')
  export "CC_$low=$BIN/${clang}21-clang" "AR_$low=$BIN/llvm-ar" \
    "CARGO_TARGET_${var}_LINKER=$BIN/${clang}21-clang" \
    "CARGO_TARGET_${var}_AR=$BIN/llvm-ar"
  cargo build --target "$target" --release
  cp "../../target/$target/release/libisar.so" \
    "$HERE/android/src/main/jniLibs/$abi/libisar.so"
  echo "built $abi"
done <<'EOF'
aarch64-linux-android aarch64-linux-android arm64-v8a
armv7-linux-androideabi armv7a-linux-androideabi armeabi-v7a
x86_64-linux-android x86_64-linux-android x86_64
i686-linux-android i686-linux-android x86
EOF
