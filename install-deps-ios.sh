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
	"boost:ios:1.64.0:zip"
	"curl:ios:7.52.1:zip"
	"nlohmann-json:ios:2.1.1:zip"
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
	unzip lib.zip

	# cleanuo
	rm lib.zip
done

# ======================================================================================================================
