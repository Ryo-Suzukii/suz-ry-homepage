#!/bin/bash

set -e

# Usage: ./deploy-pipeline.sh <environment> [profile=<aws-profile>] [--github-owner=<owner>] [--github-repo=<repo>] [--github-token=<token>]
# Example: ./deploy-pipeline.sh dev
# Example: ./deploy-pipeline.sh dev profile=my-profile
# Example: ./deploy-pipeline.sh dev --github-owner=myuser --github-repo=myrepo --github-token=ghp_xxx

ENVIRONMENT=""
CUSTOM_PROFILE=""
GITHUB_OWNER=""
GITHUB_REPO=""
GITHUB_BRANCH="main"
GITHUB_TOKEN=""
PYTHON_VERSION="python3.13"

# Parse arguments
for arg in "$@"; do
    case $arg in
        profile=*)
            CUSTOM_PROFILE="${arg#*=}"
            shift
            ;;
        --github-owner=*)
            GITHUB_OWNER="${arg#*=}"
            shift
            ;;
        --github-repo=*)
            GITHUB_REPO="${arg#*=}"
            shift
            ;;
        --github-branch=*)
            GITHUB_BRANCH="${arg#*=}"
            shift
            ;;
        --github-token=*)
            GITHUB_TOKEN="${arg#*=}"
            shift
            ;;
        python=*)
            PYTHON_VERSION="${arg#*=}"
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
    echo "Usage: $0 <environment> [options]"
    echo ""
    echo "Options:"
    echo "  profile=<aws-profile>           AWS CLI profile to use"
    echo "  python=<python-version>         Python version (default: python3.13)"
    echo "  --github-owner=<owner>          GitHub repository owner (optional)"
    echo "  --github-repo=<repo>            GitHub repository name (optional)"
    echo "  --github-branch=<branch>        GitHub branch (default: main)"
    echo "  --github-token=<token>          GitHub personal access token (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 dev profile=my-profile"
    echo "  $0 dev --github-owner=myuser --github-repo=myrepo --github-token=ghp_xxx"
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
if [ ! -f "pipeline-template.yaml" ]; then
    echo "Error: pipeline-template.yaml not found in current directory"
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

echo "Deploying Pipeline infrastructure for $ENVIRONMENT environment..."
echo "AWS Profile: $PROFILE_TO_USE"
echo "Environment Name: $ENVIRONMENT_NAME"
echo "Python Version: $PYTHON_VERSION"

# Check if S3 infrastructure exists
S3_STACK_NAME="infra-s3-${ENVIRONMENT}"
echo "Checking S3 infrastructure stack: $S3_STACK_NAME"

if ! aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$S3_STACK_NAME" \
    --query 'Stacks[0].StackStatus' \
    --output text >/dev/null 2>&1; then
    
    echo "Error: S3 infrastructure stack '$S3_STACK_NAME' not found."
    echo "Please deploy the S3 infrastructure first:"
    echo "  cd ../../infra/infra-s3"
    echo "  ./deploy.sh $ENVIRONMENT"
    exit 1
fi

# Prepare parameter overrides
PARAMETER_OVERRIDES="EnvironmentName=$ENVIRONMENT_NAME AppName=$APP_NAME PythonVersion=$PYTHON_VERSION S3StackName=infra-s3"

# Add GitHub parameters if provided
if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO" ]; then
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "Error: GitHub token is required when GitHub owner and repo are specified"
        echo "Please provide --github-token=<your-token>"
        exit 1
    fi
    
    echo "GitHub Integration: Enabled"
    echo "  Owner: $GITHUB_OWNER"
    echo "  Repository: $GITHUB_REPO"
    echo "  Branch: $GITHUB_BRANCH"
    
    PARAMETER_OVERRIDES="$PARAMETER_OVERRIDES GitHubOwner=$GITHUB_OWNER GitHubRepo=$GITHUB_REPO GitHubBranch=$GITHUB_BRANCH GitHubToken=$GITHUB_TOKEN"
else
    echo "GitHub Integration: Disabled (manual trigger only)"
fi

PIPELINE_STACK_NAME="${APP_NAME}-${ENVIRONMENT}-pipeline"
echo "Stack Name: $PIPELINE_STACK_NAME"

# Deploy CloudFormation stack
aws cloudformation deploy \
    --profile "$PROFILE_TO_USE" \
    --template-file pipeline-template.yaml \
    --stack-name "$PIPELINE_STACK_NAME" \
    --parameter-overrides $PARAMETER_OVERRIDES \
    --capabilities CAPABILITY_NAMED_IAM \
    --tags \
        Environment="$ENVIRONMENT_NAME" \
        Purpose=LambdaLayerPipeline \
        ManagedBy=CloudFormation

echo "Pipeline infrastructure deployment completed successfully!"

# Display stack outputs
echo ""
echo "=== Pipeline Infrastructure Outputs ==="
aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "$PIPELINE_STACK_NAME" \
    --query 'Stacks[0].Outputs[].{Key:OutputKey,Value:OutputValue,Description:Description}' \
    --output table

echo ""
echo "=== Next Steps ==="
echo "1. Build and deploy Lambda Layer:"
echo "   ./deploy.sh $ENVIRONMENT"
echo ""
if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO" ]; then
    echo "2. Your pipeline will automatically trigger on code changes to the $GITHUB_BRANCH branch"
    echo "   You can also manually trigger builds from the AWS Console"
else
    echo "2. To enable automatic builds on code changes, redeploy with GitHub parameters:"
    echo "   ./deploy-pipeline.sh $ENVIRONMENT --github-owner=<owner> --github-repo=<repo> --github-token=<token>"
fi
