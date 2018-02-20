#!/bin/bash
set -e

declare IOS_TOOLCHAIN='cmake/ios.toolchain.cmake'

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})
declare OUTPUT_FILE=appcom-djinni-common-ios-${VERSION}.zip

# these values are used for nexus upload - please check for correctness before using nexus deploy
declare IOS_SDK_VERSION=sdk11.2
declare IOS_COMPILER=clang

# set to TRUE to zip archive
declare ZIP_RESULTS=TRUE

# set to TRUE to deploy to Nexus (requires ZIP_RESULTS=TRUE)
declare DEPLOY_TO_NEXUS=FALSE

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
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE="${IOS_TOOLCHAIN}" -DIOS_PLATFORM=OS ../ios

# compile
make install

# fix fat file
xcrun ranlib ../output/lib/*.a

# move libraries to ios specific folder for later fat file creation
mv ../output/lib ../output/lib-ios

# cleanup build folder
rm -r ./*

# ======================================================================================================================
# build ios simulator 32 bit

# configure
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE="${IOS_TOOLCHAIN}" -DIOS_PLATFORM=SIMULATOR ../ios

# compile
make install

# move libraries to ios simulator specific folder for later fat file creation
mv ../output/lib ../output/lib-simulator

# cleanup build folder
rm -r ./*

# ======================================================================================================================
# build ios simulator 32 bit

# configure
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE="${IOS_TOOLCHAIN}" -DIOS_PLATFORM=SIMULATOR64 ../ios

# compile
make install

# move libraries to ios simulator specific folder for later fat file creation
mv ../output/lib ../output/lib-simulator64

# ======================================================================================================================
# cleanup

cd ..
rm -rf build

# ======================================================================================================================
# create fat files

declare LIBRARY_FILES=${ABSOLUTE_DIR}/output/lib-ios/*.a

mkdir output/lib || true

# iterate over all .a files
for f in $LIBRARY_FILES
do
    file=${f##*/}
    echo "Creating fat file $file ..."

    lipo -create ${ABSOLUTE_DIR}/output/lib-ios/${file} \
         ${ABSOLUTE_DIR}/output/lib-simulator/${file} \
         ${ABSOLUTE_DIR}/output/lib-simulator64/${file} \
         -output ${ABSOLUTE_DIR}/output/lib/${file}
done

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
    -DgroupId=appcom.djinni.common.ios \
    -DartifactId="${IOS_SDK_VERSION}-${IOS_COMPILER}" \
    -Dversion=${VERSION} \
    -DgeneratePom=true \
    -DrepositoryId=appcom-nexus \
    -Durl=http://appcom-nexus/nexus/content/repositories/appcom-native-libraries \
    -Dfile=${OUTPUT_FILE}
fi
