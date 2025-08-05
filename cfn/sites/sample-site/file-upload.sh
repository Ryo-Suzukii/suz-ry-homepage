#!/bin/bash

set -e

# Usage: ./file-upload.sh <environment> [profile=<aws-profile>] [--skip-build]
# Example: ./file-upload.sh dev
# Example: ./file-upload.sh dev profile=my-profile
# Example: ./file-upload.sh dev --skip-build

ENVIRONMENT=""
CUSTOM_PROFILE=""
SKIP_BUILD=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        profile=*)
            CUSTOM_PROFILE="${arg#*=}"
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        *)
            if [ -z "$ENVIRONMENT" ]; then
                ENVIRONMENT="$arg"
            else
                echo "Error: Unknown argument $arg"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if environment is provided
if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment> [profile=<aws-profile>] [--skip-build]"
    echo "Example: $0 dev"
    echo "Example: $0 dev profile=my-profile"
    echo "Example: $0 dev --skip-build"
    exit 1
fi

# Validate environment
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prd" ]; then
    echo "Error: Environment must be 'dev' or 'prd'"
    exit 1
fi

# Get current directory name as AppName
APP_NAME=$(basename "$(pwd)")

# Check if dist directory exists (after build)
if [ "$SKIP_BUILD" = false ]; then
    echo "Building React application..."
    npm run build
fi

if [ ! -d "dist" ]; then
    echo "Error: dist directory not found. Please run 'npm run build' first or infrastructure may not be deployed yet."
    exit 1
fi

# Get git repository root directory
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Not inside a git repository"
    exit 1
fi

# Read EnvironmentName from setting.json at repository root
SETTING_FILE="$GIT_ROOT/setting.json"
if [ ! -f "$SETTING_FILE" ]; then
    echo "Error: setting.json not found at $SETTING_FILE"
    exit 1
fi

ENVIRONMENT_NAME=$(jq -r '.EnvironmentName' "$SETTING_FILE")
PROFILE_PREFIX=$(jq -r '.ProfilePrefix' "$SETTING_FILE")

# Validate JSON values
if [ -z "$ENVIRONMENT_NAME" ] || [ "$ENVIRONMENT_NAME" = "null" ]; then
    echo "Error: Invalid EnvironmentName in setting.json"
    exit 1
fi

if [ -z "$PROFILE_PREFIX" ] || [ "$PROFILE_PREFIX" = "null" ]; then
    echo "Error: Invalid ProfilePrefix in setting.json"
    exit 1
fi

# Determine AWS profile
if [ -n "$CUSTOM_PROFILE" ]; then
    PROFILE_TO_USE="$CUSTOM_PROFILE"
else
    PROFILE_TO_USE="${PROFILE_PREFIX}_${ENVIRONMENT}"
fi

# Check if hosting infrastructure exists first
HOSTING_STACK_NAME="infra-hosting-${ENVIRONMENT}"
echo "Checking hosting infrastructure stack: $HOSTING_STACK_NAME"

if ! aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$HOSTING_STACK_NAME" \
    --query 'Stacks[0].StackStatus' \
    --output text >/dev/null 2>&1; then
    
    echo "Error: Hosting infrastructure stack '$HOSTING_STACK_NAME' not found."
    echo "Please deploy the hosting infrastructure first:"
    echo "  cd ../../infra/infra-hosting"
    echo "  ./deploy.sh $ENVIRONMENT"
    exit 1
fi

echo "Uploading files to $ENVIRONMENT environment..."
echo "AWS Profile: $PROFILE_TO_USE"

# Get bucket name from hosting infrastructure stack
echo "Getting S3 bucket name from hosting infrastructure..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$HOSTING_STACK_NAME" \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text 2>/dev/null)

if [ -z "$BUCKET_NAME" ] || [ "$BUCKET_NAME" = "None" ]; then
    echo "Error: Could not get bucket name from hosting infrastructure stack"
    exit 1
fi

echo "Uploading files to S3 bucket: $BUCKET_NAME"
aws s3 sync dist/ s3://$BUCKET_NAME --delete --profile "$PROFILE_TO_USE"

# Get CloudFront distribution ID from hosting infrastructure
echo "Getting CloudFront distribution ID from hosting infrastructure..."
DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$HOSTING_STACK_NAME" \
    --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
    --output text 2>/dev/null)

if [ -n "$DISTRIBUTION_ID" ] && [ "$DISTRIBUTION_ID" != "None" ]; then
    echo "Creating CloudFront invalidation for distribution: $DISTRIBUTION_ID"
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --profile "$PROFILE_TO_USE" \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    echo "CloudFront invalidation created: $INVALIDATION_ID"
    echo "Note: Invalidation may take 5-15 minutes to complete"
else
    echo "Warning: Could not get CloudFront distribution ID. Skipping invalidation."
fi

echo "File upload completed successfully!"

# Display website URLs from hosting infrastructure
echo ""
echo "Website URLs:"
aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$HOSTING_STACK_NAME" \
    --query 'Stacks[0].Outputs[?contains(OutputKey, `URL`)].{Key:OutputKey,Value:OutputValue}' \
    --output table
