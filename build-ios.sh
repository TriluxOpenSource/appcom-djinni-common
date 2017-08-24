#!/bin/bash
set -e

declare IOS_TOOLCHAIN='cmake/ios.toolchain.cmake'

# possible platforms: OS, SIMULATOR
declare IOS_PLATFORM='OS'

# ======================================================================================================================

cd $( dirname "${BASH_SOURCE[0]}" )

# cleanup possible previous build
rm -rf build || true
rm -rf output || true

# generate djinni code
./run-djinni.sh

mkdir build
cd build

# configure
cmake -DCMAKE_TOOLCHAIN_FILE="../${IOS_TOOLCHAIN}" -DIOS_PLATFORM=${IOS_PLATFORM} ../ios

# compile
make install

# fix fat file
xcrun ranlib ../output/lib/*.a

cd ..
rm -rf build

# ======================================================================================================================
#
# zip final result

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})

cd output

zip -r ac-ms-common-sdk-ios-${VERSION}.zip include lib *.yml

# cleanup
rm -r include lib *.yml
