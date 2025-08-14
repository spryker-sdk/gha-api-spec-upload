#!/bin/bash
set -euo pipefail

# This script now takes arguments and reads context from environment variables.
# Usage: ./upload.sh <api_type> <source_yaml_file>
#
# Required Environment Variables:
# - APP_TYPE:      e.g., "b2b", "b2b_marketplace", "b2c", "b2c_marketplace"
# - S3_BUCKET:     e.g., "spryker"
# - S3_PREFIX:     e.g., "docs/api-specs"
# AWS credentials are expected to be configured in the environment by a previous step.

# --- Script Arguments ---
API_TYPE=$1
SOURCE_YAML=$2
# --- End Arguments ---

# Define filenames
TARGET_JSON_FILENAME="${APP_TYPE}_${API_TYPE}_api.json"
S3_URI="s3://${S3_BUCKET}/${S3_PREFIX}/${TARGET_JSON_FILENAME}"
S3_KEY="${S3_PREFIX}/${TARGET_JSON_FILENAME}"
TEMP_JSON_FILE="temp_${TARGET_JSON_FILENAME}"

echo "--- Processing ${SOURCE_YAML} for ${APP_TYPE} / ${API_TYPE} ---"
echo "Target S3 URI: ${S3_URI}"

if [ ! -f "${SOURCE_YAML}" ]; then
    echo "Error: Source YAML file '${SOURCE_YAML}' not found."
    exit 1
fi

echo "Converting YAML to JSON..."
yq eval -o=json . "${SOURCE_YAML}" > "${TEMP_JSON_FILE}"
if [ ! -s "${TEMP_JSON_FILE}" ]; then
    echo "Error: Conversion to JSON failed or produced an empty file."
    exit 1
fi

LOCAL_MD5=$(md5sum "${TEMP_JSON_FILE}" | awk '{ print $1 }')
echo "Local file MD5: ${LOCAL_MD5}"

# Note: The ETag from a direct S3 upload is the file's MD5 hash.
# For multipart uploads, it's different. We assume direct uploads here.
REMOTE_ETAG=$(aws s3api head-object --bucket "${S3_BUCKET}" --key "${S3_KEY}" --query 'ETag' --output text 2>/dev/null | tr -d '"' || echo "not_found")
echo "Remote object ETag: ${REMOTE_ETAG}"

if [ "${LOCAL_MD5}" == "${REMOTE_ETAG}" ]; then
    echo "Content is unchanged. No upload needed for ${TARGET_JSON_FILENAME}."
else
    echo "Content has changed or is new. Uploading ${TARGET_JSON_FILENAME}..."
    aws s3 cp "${TEMP_JSON_FILE}" "${S3_URI}" --acl public-read
    echo "Upload complete."
fi

rm "${TEMP_JSON_FILE}"
echo "-------------------------------------------"