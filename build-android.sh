#!/bin/bash
set -e

declare TOOLCHAIN_VERSION=clang
declare STL_TYPE=c++_static
declare NDK_VERSION=""
declare NDK_MIN_API=19

declare COMMIT=$(git rev-list --tags --max-count=1)
declare VERSION=$(git describe --tags ${COMMIT})
declare BRANCH=$(git rev-parse --abbrev-ref HEAD)
declare OUTPUT_FILE=appcom-djinni-common-android-${VERSION}.zip

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

#=======================================================================================================================

function getAndroidNdkVersion()
{
    # get properties file that contains the ndk revision number
    local NDK_RELEASE_FILE=$ANDROID_NDK"/source.properties"
    if [ -f "${NDK_RELEASE_FILE}" ]; then
        local NDK_RN=`cat $NDK_RELEASE_FILE | grep 'Pkg.Revision' | sed -E 's/^.*[=] *([0-9]+[.][0-9]+)[.].*/\1/g'`
    else
        echo "ERROR: can not find android ndk version"
        exit 1
    fi

    # convert ndk revision number
    case "${NDK_RN#*'.'}" in
        "0")
            NDK_VERSION="r${NDK_RN%%'.'*}"
            ;;

        "1")
            NDK_VERSION="r${NDK_RN%%'.'*}b"
            ;;

        "2")
            NDK_VERSION="r${NDK_RN%%'.'*}c"
            ;;
        
        "3")
            NDK_VERSION="r${NDK_RN%%'.'*}d"
            ;;

        "4")
            NDK_VERSION="r${NDK_RN%%'.'*}e"
            ;;

        *)
            echo "Undefined or not supported Android NDK version: $NDK_RN"
            exit 1
    esac
}

# ======================================================================================================================

function build_android {

    mkdir build

    cd build

    # configure build
    cmake ../android \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_SYSTEM_VERSION=${1} \
        -DCMAKE_ANDROID_NDK=${ANDROID_NDK} \
        -DCMAKE_ANDROID_ARCH_ABI=${2} \
        -DCMAKE_ANDROID_STL_TYPE=${STL_TYPE} \
        -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=${TOOLCHAIN_VERSION}

    # compile
    make install

    cd ..
    rm -r build
}

# ======================================================================================================================

getAndroidNdkVersion

declare ARTIFACT_ID="${NDK_VERSION}-${NDK_MIN_API}-${TOOLCHAIN_VERSION}"
declare TOOLCHAIN_FILE="${ANDROID_NDK}/build/cmake/android.toolchain.cmake"

build_android 21 arm64-v8a
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

if [ "${DEPLOY_TO_NEXUS}" = "TRUE" ] && [ "${ZIP_RESULTS}" = "TRUE" ] && [ "${BRANCH}" = "master" ]; then

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
