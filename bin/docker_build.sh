#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

check_var TARGET_DIR
check_var DOCKERFILE_PATH
check_var IMAGE_NAME

# Create a lock file in /tmp (using TARGET_DIR in name to make it unique)
LOCK_FILE="/tmp/$(echo "${TARGET_DIR}" | sed 's/\//_/g').lock"
touch "$LOCK_FILE"

# Create a temporary build directory
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

# Acquire lock while copying files
echo "Acquiring lock for copying files..."
(
    if ! flock -n 9; then
        echo "Error: Another process is currently copying files"
        exit 1
    fi

    # Copy the target directory contents to the build directory
    cp -r "$TARGET_DIR"/* "$BUILD_DIR"
) 9>"$LOCK_FILE"

# Change to the build directory
cd "$BUILD_DIR"
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" .

# Push the image to the registry
docker push "${IMAGE_NAME}"
