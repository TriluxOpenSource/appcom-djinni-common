#!/bin/bash
set -e

declare TOOLCHAIN_VERSION=clang
declare STL_TYPE=c++_static
declare NDK_VERSION=r16b
declare NDK_MIN_API=19

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})
declare OUTPUT_FILE=appcom-djinni-common-android-${VERSION}.zip
declare ARTIFACT_ID="${NDK_VERSION}-${NDK_MIN_API}-${TOOLCHAIN_VERSION}"
declare NDK_PATH="/opt/android-ndks/android-ndk-${NDK_VERSION}"

# set to TRUE to zip archive
declare ZIP_RESULTS=TRUE

# set to TRUE to deploy to Nexus (requires ZIP_RESULTS=TRUE)
declare DEPLOY_TO_NEXUS=FALSE

# ======================================================================================================================

cd $( dirname "${BASH_SOURCE[0]}" )

# check that the android ndk path is set
if [ -z "${ANDROID_NDK}" ]; then 
    echo >&2 "ANDROID_NDK is not set - please set ANDROID_NDK to the path of your android ndk installation."; exit 1;
fi

# cleanup possible previous build
rm -r build || true
rm -r output/* || true

# generate djinni code
./run-djinni.sh

# ======================================================================================================================

function build_android {

    mkdir build

    cd build

    # configure build
    cmake ../android \
        -DCMAKE_BUILD_TYPE=RELEASE \
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
build_android 19 x86
build_android 21 x86_64

# ======================================================================================================================
#
# zip final result

if [ "${ZIP_RESULTS}" = "TRUE" ]; then

    cd output

    zip -r ${OUTPUT_FILE} include lib jni *.yml

    # cleanup
    rm -r include lib jni *.yml
fi

# ======================================================================================================================
#
# upload to nexus

if [ "${DEPLOY_TO_NEXUS}" = "TRUE" ] && [ "${ZIP_RESULTS}" = "TRUE" ]; then

    # check if maven is installed
    command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

    mvn deploy:deploy-file -e \
    -DgroupId=appcom.djinni.common.android \
    -DartifactId=${ARTIFACT_ID} \
    -Dversion=${VERSION} \
    -DgeneratePom=true \
    -DrepositoryId=appcom-nexus \
    -Durl=http://appcom-nexus/nexus/content/repositories/appcom-native-libraries \
    -Dfile=${OUTPUT_FILE}
fi
