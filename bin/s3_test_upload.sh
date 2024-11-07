#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

echo "Starting s3 test upload validation"

# Create temporary test file
TEST_FILE="/tmp/check-access.txt"

# Generate content for the test file
{
    echo "https://ptah.sh"
    echo "Test upload date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "S3 Endpoint: $S3_ENDPOINT"
    echo "S3 Region: $S3_REGION"
    echo "S3 Bucket: $S3_BUCKET"
    echo "Path Prefix: $PATH_PREFIX"
} > "$TEST_FILE"

echo "Created test file with the following content:"
cat "$TEST_FILE"

# Set up environment variables for s3_upload.sh
export ARCHIVE_FORMAT=""
export SRC_FILE_PATH="$TEST_FILE"
export DEST_FILE_PATH="check-access.txt"

# Call the main upload script
"$(dirname "$0")/s3_upload.sh"

echo "Test upload completed successfully"
