#!/bin/bash

set -e

# Usage: ./deploy.sh <environment> [profile=<aws-profile>]
# Example: ./deploy.sh dev
# Example: ./deploy.sh dev profile=my-profile

ENVIRONMENT=""
CUSTOM_PROFILE=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        profile=*)
            CUSTOM_PROFILE="${arg#*=}"
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
    echo "Usage: $0 <environment> [profile=<aws-profile>]"
    echo "Example: $0 dev"
    echo "Example: $0 dev profile=my-profile"
    exit 1
fi

# Validate environment
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prd" ]; then
    echo "Error: Environment must be 'dev' or 'prd'"
    exit 1
fi

# Get current directory name as AppName
APP_NAME=$(basename "$(pwd)")

# Check if template.yaml exists
if [ ! -f "template.yaml" ]; then
    echo "Error: template.yaml not found in current directory"
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

# Determine AWS profile
if [ -n "$CUSTOM_PROFILE" ]; then
    # Use custom profile if provided
    PROFILE_TO_USE="$CUSTOM_PROFILE"
elif [ -n "$AWS_PROFILE" ]; then
    # Use AWS_PROFILE environment variable if set
    PROFILE_TO_USE="$AWS_PROFILE"
else
    # Default to hoge_{environment} pattern
    PROFILE_TO_USE="hoge_${ENVIRONMENT}"
fi

echo "Building React application..."
npm run build

echo "Deploying $APP_NAME to $ENVIRONMENT environment..."
echo "AWS Profile: $PROFILE_TO_USE"
echo "Environment Name: $ENVIRONMENT_NAME"

# Deploy using CloudFormation
aws cloudformation deploy \
    --profile "$PROFILE_TO_USE" \
    --template-file template.yaml \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --parameter-overrides \
        EnvironmentName="$ENVIRONMENT_NAME" \
        AppName="$APP_NAME" \
    --capabilities CAPABILITY_IAM

echo "Getting bucket name from CloudFormation stack..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text)

echo "Uploading files to S3 bucket: $BUCKET_NAME"
aws s3 sync dist/ s3://$BUCKET_NAME --delete --profile "$PROFILE_TO_USE"

echo "Getting CloudFront distribution URL..."
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)

if [ ! -z "$CLOUDFRONT_URL" ]; then
    DISTRIBUTION_ID=$(echo "$CLOUDFRONT_URL" | sed 's/https:\/\///' | sed 's/\.cloudfront\.net//')
    echo "Creating CloudFront invalidation for distribution: $DISTRIBUTION_ID"
    aws cloudfront create-invalidation \
        --profile "$PROFILE_TO_USE" \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/*"
fi

echo "Deployment completed successfully!"

# Display URLs
echo ""
echo "Website URLs:"
aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --query 'Stacks[0].Outputs[?contains(OutputKey, `URL`)].{Key:OutputKey,Value:OutputValue}' \
    --output table