#!/bin/bash
set -e

declare IOS_TOOLCHAIN='cmake/ios.toolchain.cmake'

# possible platforms: OS, SIMULATOR
declare IOS_PLATFORM='OS'

# ======================================================================================================================

cd $( dirname "${BASH_SOURCE[0]}" )
./run_djinni.sh

# cleanup possible previous build
rm -rf build || true

mkdir build
cd build

# configure
cmake -DCMAKE_TOOLCHAIN_FILE="../${IOS_TOOLCHAIN}" -DIOS_PLATFORM=${IOS_PLATFORM} ../ios

# compile
make install

# fix fat file
xcrun ranlib ../output/ios/lib/*.a

cd ..
rm -rf build
