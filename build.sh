#!/usr/bin/env bash

set -x

XZ_VERSION="xz-5.2.7"
PWD_MAIN="$(pwd)"
PREFIX="$PWD_MAIN/bin"

$ESM_BUILD && PREFIX="$PWD_MAIN/dist"

# Downloading the source code archive


if ! [ -f $XZ_VERSION.tar.gz ]; then
  curl https://tukaani.org/xz/$XZ_VERSION.tar.gz -OL
fi

# Extracting source code

rm -r build $PREFIX $XZ_VERSION

tar -xf $XZ_VERSION.tar.gz

mkdir build -p
mkdir $PREFIX -p

cd build

export CFLAGS="-O3"
export LDFLAGS="$CFLAGS -s INITIAL_MEMORY=16MB -s ALLOW_MEMORY_GROWTH=1";

$ESM_BUILD && export LDFLAGS="$LDFLAGS -s STRICT_JS=1 -s MODULARIZE=1 -s EXPORT_NAME=XZFactory -s EXPORTED_RUNTIME_METHODS=FS,WORKERFS,MEMFS,ENV -s EXPORT_ES6=1 -s USE_ES6_IMPORT_META=1";

emconfigure ../$XZ_VERSION/configure \
  --host=wasm32-unknown-none \
  --prefix="$PREFIX" \
  --enable-static \
  --disable-doc \
  --disable-scripts \
  --disable-lzma-links \
  --disable-lzmainfo \
  --disable-lzmadec\
  --enable-assume-ram=512 \
  --enable-threads=no \
  --disable-assembler \
  --disable-nls

rm $(find -type f -name "*.wasm")

emmake make

emmake make install

cp $(find -type f -name "*.wasm") $PREFIX/bin/

cd $PREFIX/bin/

for f in $(find -type f ! -name "*.*")
do
  ( $ESM_BUILD && cp $f $f.mjs ) || cp $f $f.js
done

