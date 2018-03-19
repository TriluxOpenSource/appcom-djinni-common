#!/bin/bash
set -e

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})
declare OUTPUT_FILE=appcom-djinni-common-macos-${VERSION}.zip

# these values are used for nexus upload - please check for correctness before using nexus deploy
declare MACOS_COMPILER=clang

# set to TRUE to zip archive
declare ZIP_RESULTS=TRUE

# set to TRUE to deploy to Nexus (requires ZIP_RESULTS=TRUE)
declare DEPLOY_TO_NEXUS=TRUE

# ======================================================================================================================
# prepare build

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# cleanup possible previous build
rm -rf build || true
rm -rf output || true

# generate djinni code
./run-djinni.sh

mkdir build
cd build

# ======================================================================================================================
# build ios

# configure
cmake -DCMAKE_BUILD_TYPE=RELEASE ../macos

# compile
make install

# fix fat file
xcrun ranlib ../output/lib/*.a

# cleanup
cd ..
rm -rf build

# ======================================================================================================================
# zip final result

if [ "${ZIP_RESULTS}" = "TRUE" ]; then

    cd output

    zip -r ${OUTPUT_FILE} include lib *.yml

    # cleanup
    rm -r include lib *.yml
fi

# ======================================================================================================================
# upload to nexus

if [ "${DEPLOY_TO_NEXUS}" = "TRUE" ] && [ "${ZIP_RESULTS}" = "TRUE" ]; then

    # check if maven is installed
    command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

    mvn deploy:deploy-file -e \
    -DgroupId=appcom.djinni.common.macos \
    -DartifactId="${MACOS_COMPILER}" \
    -Dversion=${VERSION} \
    -DgeneratePom=true \
    -DrepositoryId=appcom-nexus \
    -Durl=http://appcom-nexus/nexus/content/repositories/appcom-native-libraries \
    -Dfile=${OUTPUT_FILE}
fi
