#!/bin/sh

set -e

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

echo "Starting s3 upload script validation"

check_var SRC_FILE_PATH
check_var DEST_FILE_PATH
check_var S3_ACCESS_KEY
check_var S3_SECRET_KEY
check_var S3_ENDPOINT
check_var S3_REGION
check_var S3_BUCKET
check_var PATH_PREFIX

SRC_FILE_PATH="/$SRC_FILE_PATH"

if [ -n "$ARCHIVE_FORMAT" ]; then
    if [ -d "$SRC_FILE_PATH" ]; then
        cd "$SRC_FILE_PATH"
    else
        cd "$(dirname "$SRC_FILE_PATH")"
    fi

    echo "Archiving $SRC_FILE_PATH"

    ARCHIVED_FILE="/tmp/archive.$ARCHIVE_FORMAT"

    case "$ARCHIVE_FORMAT" in
        "tar.gz")
            tar -czvf "$ARCHIVED_FILE" "."
            ;;
        "zip")
            apk add zip
            zip -r "$ARCHIVED_FILE" "."
            ;;
        *)
            echo "Unsupported archive format: $ARCHIVE_FORMAT"
            exit 1
            ;;
    esac
    
    UPLOAD_FILE="$ARCHIVED_FILE"
else
    UPLOAD_FILE="$SRC_FILE_PATH"
fi

echo "Uploading $UPLOAD_FILE to s3://$S3_BUCKET/$PATH_PREFIX/$DEST_FILE_PATH"

s3cmd --guess-mime-type \
    --access_key "$S3_ACCESS_KEY" \
    --secret_key "$S3_SECRET_KEY" \
    --host "$S3_ENDPOINT" \
    --host-bucket "$S3_ENDPOINT" \
    --region "$S3_REGION" \
    put "$UPLOAD_FILE" "s3://$S3_BUCKET/$PATH_PREFIX/$DEST_FILE_PATH"

if [ -n "$ARCHIVE_FORMAT" ]; then
    echo "Removing $ARCHIVED_FILE"
    rm -f "$ARCHIVED_FILE"
fi

echo "Done"
