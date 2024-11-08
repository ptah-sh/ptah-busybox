#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"
. "$(dirname "$0")/../lib/sync.sh"

check_var TARGET_DIR
check_var DOCKERFILE_PATH
check_var IMAGE_NAME

# Create a temporary build directory
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

copy_files() {
    cp -r "$TARGET_DIR"/* "$BUILD_DIR"
}

with_lock "${TARGET_DIR}" copy_files

# Change to the build directory
cd "$BUILD_DIR"
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" .

# Push the image to the registry
docker push "${IMAGE_NAME}"
