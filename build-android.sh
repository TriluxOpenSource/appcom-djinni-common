#!/bin/bash
set -e

declare NDK_PATH='/Users/gordon/Library/Android/sdk/ndk-bundle'
declare TOOLCHAIN_VERSION=clang
declare STL_TYPE=c++_static

# ======================================================================================================================

cd $( dirname "${BASH_SOURCE[0]}" )

# cleanup possible previous build
rm -r build || true
rm -r output || true

# generate djinni code
./run-djinni.sh

# ======================================================================================================================

function build_android {

    mkdir build

    cd build

    # configure build
    cmake ../android \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=${1} \
    -DCMAKE_ANDROID_NDK=${NDK_PATH} \
    -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=${TOOLCHAIN_VERSION} \
    -DCMAKE_ANDROID_ARCH_ABI=${2} \
    -DCMAKE_ANDROID_STL_TYPE=${STL_TYPE}

    # compile
    make install

    cd ..
    rm -r build
}

# ======================================================================================================================

build_android 21 arm64-v8a
build_android 19 armeabi
build_android 19 armeabi-v7a
build_android 19 mips
#build_android 21 mips64
build_android 19 x86
build_android 21 x86_64

# ======================================================================================================================
#
# zip final result

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})

cd output

zip -r ac-ms-common-sdk-android-${VERSION}.zip include lib java *.yml

# cleanup
rm -r include lib *.yml
