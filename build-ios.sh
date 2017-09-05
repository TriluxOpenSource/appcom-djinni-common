#!/bin/bash
set -e

declare IOS_TOOLCHAIN='cmake/ios.toolchain.cmake'

# possible platforms: OS, SIMULATOR
declare IOS_PLATFORM='OS'

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})
declare OUTPUT_FILE=ac-ms-common-sdk-ios-${VERSION}.zip

# set to TRUE to zip archive
declare ZIP_RESULTS=FALSE

# set to TRUE to deploy to Nexus (requires ZIP_RESULTS=TRUE)
declare DEPLOY_TO_NEXUS=FALSE

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

if [ "${ZIP_RESULTS}" = "TRUE" ]; then

    cd output

    zip -r ${OUTPUT_FILE} include lib *.yml

    # cleanup
    rm -r include lib *.yml
fi

# ======================================================================================================================
#
# upload to nexus

if [ "${DEPLOY_TO_NEXUS}" = "TRUE" ] && [ "${ZIP_RESULTS}" = "TRUE" ]; then

    # check if maven is installed
    command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

    mvn deploy:deploy-file -e \
    -DgroupId=ac-ms-common-sdk \
    -DartifactId=ios \
    -Dversion=${VERSION} \
    -DgeneratePom=true \
    -DrepositoryId=appcom-nexus \
    -Durl=http://appcom-nexus/nexus/content/repositories/appcom-microservice-sdks \
    -Dfile=${OUTPUT_FILE}
fi
