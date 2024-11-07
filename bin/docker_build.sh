#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

check_var TARGET_DIR
check_var DOCKERFILE_PATH
check_var IMAGE_NAME
check_var REGISTRY_URL

# Create a temporary build directory
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

# Copy the target directory contents to the build directory
cp -r "$TARGET_DIR"/* "$BUILD_DIR"

# Change to the build directory
cd "$BUILD_DIR"
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" .

# Tag the image with the registry URL
docker tag "$IMAGE_NAME" "${REGISTRY_URL}/${IMAGE_NAME}"

# Push the image to the registry
docker push "${REGISTRY_URL}/${IMAGE_NAME}"
