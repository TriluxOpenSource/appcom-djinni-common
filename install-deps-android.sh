#!/usr/bin/env bash
set -e

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ======================================================================================================================
# settings

declare NEXUS_REPOSITORY_ID=appcom-nexus
declare NEXUS_REPOSITORY_URL=http://appcom-nexus/nexus/content/repositories
declare NEXUS_REPOSITORY_NATIVE_LIBRARIES=${NEXUS_REPOSITORY_URL}/appcom-native-libraries

# add all native libraries to this array that needs to be installed
declare NATIVE_LIBRARIES=(
	"boost.android:r16b-15-clang:1.66.0:zip"
	"nlohmann-json:android:3.1.1:zip"
	"dropbox-djinni:android:428:zip"
	)

# ======================================================================================================================

# check if maven is installed
command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven 2 is required but it's not installed. Aborting."; exit 1; }

# ======================================================================================================================

# cleanup and recreate
rm -r android/include android/lib || true
cd android

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
