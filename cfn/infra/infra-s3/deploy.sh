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
elif [ -n "$AWS_PROFILE" ]; then
    PROFILE_TO_USE="$AWS_PROFILE"
else
    PROFILE_TO_USE="${PROFILE_PREFIX}_${ENVIRONMENT}"
fi

echo "Deploying S3 infrastructure for $ENVIRONMENT environment..."
echo "AWS Profile: $PROFILE_TO_USE"
echo "Environment Name: $ENVIRONMENT_NAME"
echo "Stack Name: ${APP_NAME}-${ENVIRONMENT}"

# Deploy CloudFormation stack
aws cloudformation deploy \
    --profile "$PROFILE_TO_USE" \
    --template-file template.yaml \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --parameter-overrides \
        EnvironmentName="$ENVIRONMENT_NAME" \
        AppName="$APP_NAME" \
    --capabilities CAPABILITY_IAM \
    --tags \
        Environment="$ENVIRONMENT_NAME" \
        Purpose=S3Storage \
        ManagedBy=CloudFormation

echo "S3 infrastructure deployment completed successfully!"

# Display stack outputs
echo ""
echo "=== S3 Infrastructure Outputs ==="
aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --query 'Stacks[0].Outputs[].{Key:OutputKey,Value:OutputValue,Description:Description}' \
    --output table

echo ""
echo "=== Usage Instructions ==="
echo "These S3 buckets can be used by other stacks by referencing the exported values:"
echo ""
echo "CloudFormation Import Examples:"
echo "  LambdaLayerBucket: !ImportValue ${APP_NAME}-${ENVIRONMENT}-LambdaLayerBucketName"
echo "  CodePipelineBucket: !ImportValue ${APP_NAME}-${ENVIRONMENT}-CodePipelineBucketName"
echo "  CloudFormationBucket: !ImportValue ${APP_NAME}-${ENVIRONMENT}-CloudFormationBucketName"
echo "  ApplicationDataBucket: !ImportValue ${APP_NAME}-${ENVIRONMENT}-ApplicationDataBucketName"
echo ""
echo "AWS CLI Examples:"
echo "  LAMBDA_BUCKET=\$(aws cloudformation describe-stacks --stack-name ${APP_NAME}-${ENVIRONMENT} --query 'Stacks[0].Outputs[?OutputKey==\`LambdaLayerBucketName\`].OutputValue' --output text --profile $PROFILE_TO_USE)"
echo "  PIPELINE_BUCKET=\$(aws cloudformation describe-stacks --stack-name ${APP_NAME}-${ENVIRONMENT} --query 'Stacks[0].Outputs[?OutputKey==\`CodePipelineBucketName\`].OutputValue' --output text --profile $PROFILE_TO_USE)"