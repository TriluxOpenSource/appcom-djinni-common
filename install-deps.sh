#!/usr/bin/env bash
set -e

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ======================================================================================================================
# settings

declare NEXUS_REPOSITORY_ID=appcom-nexus
declare NEXUS_REPOSITORY_URL=http://appcom-nexus/nexus/content/repositories
declare NEXUS_REPOSITORY_NATIVE_LIBRARIES=${NEXUS_REPOSITORY_URL}/appcom-native-libraries

declare PLATFORM=$1

# add all native libraries to this array that needs to be installed
declare NATIVE_LIBRARIES=(
	"boost:${PLATFORM}:1.64.0:zip"
	"curl:${PLATFORM}:7.52.1:zip"
	)

# ======================================================================================================================

# check if maven is installed
command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

# ======================================================================================================================

# check supported platforms
if [ "${PLATFORM}" != "ios" ] && [ "${PLATFORM}" != "android" ]; then
    
    echo "Platform '${PLATFORM}' is not supported. You may choose from 'android' or 'ios'."
    exit 1
fi

# ======================================================================================================================

# cleanup and recreate
rm -r ${PLATFORM}/include ${PLATFORM}/lib || true
cd ${PLATFORM}

# ======================================================================================================================
# download and install all native libraries

for library in ${NATIVE_LIBRARIES[@]}; do
	
	# download
	mvn dependency:get -e \
	  -Dartifact=${library} \
	  -Dtransitive=false \
	  -DremoteRepositories=${NEXUS_REPOSITORY_ID}::::${NEXUS_REPOSITORY_NATIVE_LIBRARIES} \
	  -Ddest=lib.zip

	# extract zip archive
	unzip lib.zip

	# cleanuo
	rm lib.zip
done

# ======================================================================================================================
