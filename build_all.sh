#!/bin/bash

BUILD_PATH="/storage/build"
MAKE_PARALLEL="-j4"

echo "Configure environment..."

#---------------------------------------------------------------------
#update apt
apt-get update
apt-get dist-upgrade -y

#---------------------------------------------------------------------
#configure tzdata
export DEBIAN_FRONTEND=noninteractive
apt-get install -y tzdata
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

#---------------------------------------------------------------------
#add repos
apt-get install -y software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update
apt-get dist-upgrade -y

#---------------------------------------------------------------------
#install sowtware
apt-get install -y vim mc cmake libboost1.71-all-dev gcc-10 g++-10 git

#install emscripten
mkdir -p /storage/emscripten
cd /storage/emscripten
git clone https://github.com/emscripten-core/emsdk.git
cd /storage/emscripten/emsdk
git pull
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

#install jthread
mkdir -p $BUILD_PATH/inc
cd $BUILD_PATH/inc
git clone https://github.com/josuttis/jthread.git

#---------------------------------------------------------------------
#clone projects from github and build (GpCore2)
mkdir -p $BUILD_PATH/src
cd $BUILD_PATH/src
git clone -b master https://github.com/ITBear/GpCore2.git
cd $BUILD_PATH/src/GpCore2

#linux build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
cmake . -DBUILD_RELEASE_LINUX_x86_64=ON && make $MAKE_PARALLEL && make install

#webassembly build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
emcmake cmake . -DBUILD_RELEASE_WASM32=ON && emmake make $MAKE_PARALLEL

#---------------------------------------------------------------------
#clone projects from github and build (utf8proc)
mkdir -p $BUILD_PATH/src && cd $BUILD_PATH/src
git clone -b master https://github.com/ITBear/utf8proc.git && cd $BUILD_PATH/src/utf8proc

#linux build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
cmake . -DBUILD_RELEASE_LINUX_x86_64=ON && make $MAKE_PARALLEL && make install

#webassembly build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
emcmake cmake . -DBUILD_RELEASE_WASM32=ON && emmake make $MAKE_PARALLEL

#---------------------------------------------------------------------
#clone projects from github and build (libsodium)
mkdir -p $BUILD_PATH/src && cd $BUILD_PATH/src
git clone -b master https://github.com/jedisct1/libsodium.git
cd $BUILD_PATH/src/libsodium
git checkout 26a7c82033a82eed00761a5ea4a7261513fbd45c
$BUILD_PATH/src/libsodium/autogen.sh
$BUILD_PATH/src/libsodium/dist-build/emscripten.sh --standard
cp $BUILD_PATH/src/libsodium/libsodium-js/lib/libsodium.a $BUILD_PATH/src/libsodium/../../bin/Release_Browser_wasm32/libsodium.a
cp -r $BUILD_PATH/src/libsodium/libsodium-js/include/ $BUILD_PATH/src/libsodium/../../inc/libsodium
make distclean
$BUILD_PATH/src/libsodium/configure CC=gcc-10 --enable-shared=yes
make $MAKE_PARALLEL
cp $BUILD_PATH/src/libsodium/src/libsodium/.libs/libsodium.so* $BUILD_PATH/src/libsodium/../../bin/Release_Linux_x86_64

#---------------------------------------------------------------------
#clone projects from github and build (GpCryptoCore)
mkdir -p $BUILD_PATH/src
cd $BUILD_PATH/src
git clone -b master https://github.com/ITBear/GpCryptoCore.git
cd $BUILD_PATH/src/GpCryptoCore

#linux build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
cmake . -DBUILD_RELEASE_LINUX_x86_64=ON && make $MAKE_PARALLEL && make install

#webassembly build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
emcmake cmake . -DBUILD_RELEASE_WASM32=ON && emmake make $MAKE_PARALLEL

#---------------------------------------------------------------------
#clone projects from github and build (UnoSemuxLightCore)
mkdir -p $BUILD_PATH/src
cd $BUILD_PATH/src
git clone -b master https://github.com/uno-labs/UnoSemuxLightCore.git
cd $BUILD_PATH/src/UnoSemuxLightCore

#linux build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
cmake . -DBUILD_RELEASE_LINUX_x86_64=ON && make $MAKE_PARALLEL && make install

#webassembly build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
emcmake cmake . -DBUILD_RELEASE_WASM32=ON && emmake make $MAKE_PARALLEL

#---------------------------------------------------------------------
#clone projects from github and build (UnoSemuxLightCoreWasm)
mkdir -p $BUILD_PATH/src
cd $BUILD_PATH/src
git clone -b master https://github.com/uno-labs/UnoSemuxLightCoreWasm.git
cd $BUILD_PATH/src/UnoSemuxLightCoreWasm

#linux build (NO: UnoSemuxLightCoreWasm This library can be build only with EMSCRIPTEN)

#webassembly build
rm -rfd ./CMakeFiles && rm -f ./CMakeCache.txt && rm -f ./cmake_install.cmake
emcmake cmake . -DBUILD_RELEASE_WASM32=ON && emmake make $MAKE_PARALLEL

#---------------------------------------------------------------------
echo "Building done..."
echo "All binary files places to '"$BUILD_PATH"/bin/'"
echo "All inlude files places to '"$BUILD_PATH"/inc/'"
echo "All source files places to '"$BUILD_PATH"/src/'"
