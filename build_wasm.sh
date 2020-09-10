#!/bin/bash

ROOT="$(dirname $(readlink -f $0))"
BUILD_PATH=$ROOT/build

git submodule update --init --recursive

cd $ROOT/vendor/emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

cd $BUILD_PATH/src/GpCore2
sed -i -e 's/cmake_minimum_required(VERSION 3.16)/cmake_minimum_required(VERSION 3.12.4)/g' ./CMakeLists.txt
[ ! -f "cmake_install.cmake" ] && emcmake cmake . -DBUILD_RELEASE_WASM32=ON
emmake make

cd $BUILD_PATH/src/utf8proc
sed -i -e 's/cmake_minimum_required(VERSION 3.16)/cmake_minimum_required(VERSION 3.12.4)/g' ./CMakeLists.txt
[ ! -f "cmake_install.cmake" ] && emcmake cmake . -DBUILD_RELEASE_WASM32=ON
emmake make

cd $BUILD_PATH/src/libsodium
[ ! -f "configure" ] && $BUILD_PATH/src/libsodium/autogen.sh
[ ! -f "$BUILD_PATH/src/libsodium/libsodium-js/lib/libsodium.a" ] && $BUILD_PATH/src/libsodium/dist-build/emscripten.sh --standard
cp $BUILD_PATH/src/libsodium/libsodium-js/lib/libsodium.a $BUILD_PATH/src/libsodium/../../bin/Release_Browser_wasm32/libsodium.a
cp -r $BUILD_PATH/src/libsodium/libsodium-js/include/ $BUILD_PATH/src/libsodium/../../inc/libsodium

cd $BUILD_PATH/src/GpCryptoCore
sed -i -e 's/cmake_minimum_required(VERSION 3.16)/cmake_minimum_required(VERSION 3.12.4)/g' ./CMakeLists.txt
[ ! -f "cmake_install.cmake" ] && emcmake cmake . -DBUILD_RELEASE_WASM32=ON
emmake make

cd $BUILD_PATH/src/UnoSemuxLightCore
sed -i -e 's/cmake_minimum_required(VERSION 3.16)/cmake_minimum_required(VERSION 3.12.4)/g' ./CMakeLists.txt
[ ! -f "cmake_install.cmake" ] && emcmake cmake . -DBUILD_RELEASE_WASM32=ON
emmake make

cd $BUILD_PATH/src/UnoSemuxLightCoreWasm
sed -i -e 's/cmake_minimum_required(VERSION 3.16)/cmake_minimum_required(VERSION 3.12.4)/g' ./CMakeLists.txt
[ ! -f "cmake_install.cmake" ] && emcmake cmake . -DBUILD_RELEASE_WASM32=ON
emmake make
