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
	"boost.ios:sdk11.3-clang:1.67.0:zip"
	"nlohmann-json:ios:3.1.1:zip"
	"dropbox-djinni.ios:sdk11.2-clang:440:zip"
	)

# ======================================================================================================================

# check if maven is installed
command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

# ======================================================================================================================

# cleanup and recreate
rm -r ios/include ios/lib || true
cd ios

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
	unzip -o lib.zip

	# cleanuo
	rm lib.zip
done

# ======================================================================================================================
