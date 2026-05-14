#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------
# Terraform state backend bootstrap.
# Creates an S3 bucket (versioned, encrypted, locked-down) for state files
# and a DynamoDB table for state locking. Run this ONCE per project.
# ---------------------------------------------------------------------

AWS_PROFILE="hameed-admin"
AWS_REGION="eu-west-2"
BUCKET_NAME="terraform-state-hameed-eks-platform"     # must be globally unique
TABLE_NAME="terraform-state-locks"

echo "==> Creating S3 bucket: ${BUCKET_NAME}"
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${AWS_REGION}" \
  --create-bucket-configuration LocationConstraint="${AWS_REGION}" \
  --profile "${AWS_PROFILE}"

echo "==> Enabling versioning on bucket"
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled \
  --profile "${AWS_PROFILE}"

echo "==> Enabling default encryption (SSE-S3)"
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }' \
  --profile "${AWS_PROFILE}"

echo "==> Blocking all public access to bucket"
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --profile "${AWS_PROFILE}"

echo "==> Creating DynamoDB lock table: ${TABLE_NAME}"
aws dynamodb create-table \
  --table-name "${TABLE_NAME}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${AWS_REGION}" \
  --profile "${AWS_PROFILE}"

echo ""
echo "✅ Bootstrap complete."
echo "   Bucket:   ${BUCKET_NAME}"
echo "   Table:    ${TABLE_NAME}"
echo "   Region:   ${AWS_REGION}"