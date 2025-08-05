#!/bin/bash

set -e

# Usage: ./deploy.sh <environment> [profile=<aws-profile>] [--skip-build]
# Example: ./deploy.sh dev
# Example: ./deploy.sh dev profile=my-profile
# Example: ./deploy.sh dev --skip-build

ENVIRONMENT=""
CUSTOM_PROFILE=""
SKIP_BUILD=false
PYTHON_VERSION="python3.13"

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
    echo "Usage: $0 <environment> [profile=<aws-profile>] [--skip-build] [python=<version>]"
    echo "Example: $0 dev"
    echo "Example: $0 dev profile=my-profile"
    echo "Example: $0 dev --skip-build"
    echo "Example: $0 dev python=python3.12"
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
else
    PROFILE_TO_USE="${PROFILE_PREFIX}_${ENVIRONMENT}"
fi

echo "Deploying Lambda Layer for $ENVIRONMENT environment..."
echo "AWS Profile: $PROFILE_TO_USE"
echo "Environment Name: $ENVIRONMENT_NAME"
echo "Python Version: $PYTHON_VERSION"
echo "Stack Name: ${APP_NAME}-${ENVIRONMENT}"

# Build Lambda Layer using CodeBuild if not skipped
if [ "$SKIP_BUILD" = false ]; then
    echo ""
    echo "=== Building Lambda Layer with CodeBuild ==="
    
    # Check if requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        echo "Error: requirements.txt not found"
        exit 1
    fi
    
    # Check if CodeBuild project exists
    CODEBUILD_PROJECT_NAME="${APP_NAME}-${ENVIRONMENT}-layer-builder"
    
    echo "Checking if CodeBuild project exists: $CODEBUILD_PROJECT_NAME"
    
    # Check if CodeBuild project exists
    PIPELINE_STACK_NAME="${APP_NAME}-${ENVIRONMENT}-pipeline"
    
    if ! aws cloudformation describe-stacks \
        --profile "$PROFILE_TO_USE" \
        --stack-name "$PIPELINE_STACK_NAME" \
        --query 'Stacks[0].StackStatus' \
        --output text >/dev/null 2>&1; then
        
        echo "Error: Pipeline infrastructure stack '$PIPELINE_STACK_NAME' not found."
        echo "Please deploy the pipeline infrastructure first:"
        echo ""
        echo "1. Make sure S3 infrastructure is deployed:"
        echo "   cd ../../infra/infra-s3"
        echo "   ./deploy.sh $ENVIRONMENT"
        echo ""
        echo "2. Deploy pipeline infrastructure:"
        echo "   ./deploy-pipeline.sh $ENVIRONMENT"
        exit 1
    fi
    
    # Double-check that CodeBuild project actually exists
    if ! aws codebuild batch-get-projects \
        --names "$CODEBUILD_PROJECT_NAME" \
        --profile "$PROFILE_TO_USE" \
        --query 'projects[0].name' \
        --output text >/dev/null 2>&1; then
        
        echo "Error: CodeBuild project '$CODEBUILD_PROJECT_NAME' not found in pipeline stack."
        echo "Pipeline stack exists but CodeBuild project is missing."
        echo "This might be a deployment issue. Try redeploying the pipeline:"
        echo ""
        echo "   ./deploy-pipeline.sh $ENVIRONMENT"
        exit 1
    fi
    
    echo "Starting CodeBuild project: $CODEBUILD_PROJECT_NAME"
    
    # Create temporary source bundle
    TEMP_DIR=$(mktemp -d)
    cp requirements.txt "$TEMP_DIR/"
    cp buildspec.yml "$TEMP_DIR/" 2>/dev/null || echo "buildspec.yml not found, using inline buildspec from pipeline"
    
    # Create source ZIP for CodeBuild
    cd "$TEMP_DIR"
    zip -r source.zip . -q
    cd - >/dev/null
    
    # Get S3 bucket from external S3 stack
    S3_STACK_NAME="infra-s3-${ENVIRONMENT}"
    
    # Check if S3 stack exists
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
    
    # Get pipeline bucket from S3 stack
    PIPELINE_BUCKET=$(aws cloudformation describe-stacks \
        --profile "$PROFILE_TO_USE" \
        --stack-name "$S3_STACK_NAME" \
        --query 'Stacks[0].Outputs[?OutputKey==`CodePipelineBucketName`].OutputValue' \
        --output text 2>/dev/null)
    
    if [ -z "$PIPELINE_BUCKET" ] || [ "$PIPELINE_BUCKET" = "None" ]; then
        echo "Error: Could not get CodePipeline bucket name from S3 stack"
        exit 1
    fi
    
    SOURCE_KEY="sources/$(date +%Y%m%d-%H%M%S)-source.zip"
    
    aws s3 cp "$TEMP_DIR/source.zip" "s3://$PIPELINE_BUCKET/$SOURCE_KEY" --profile "$PROFILE_TO_USE"
    
    # Start CodeBuild
    BUILD_ID=$(aws codebuild start-build \
        --project-name "$CODEBUILD_PROJECT_NAME" \
        --source-type S3 \
        --source-location "$PIPELINE_BUCKET/$SOURCE_KEY" \
        --environment-variables-override \
            name=PYTHON_VERSION,value="$PYTHON_VERSION" \
            name=LAYER_NAME,value=common-libraries \
            name=ENVIRONMENT_NAME,value="$ENVIRONMENT_NAME" \
        --profile "$PROFILE_TO_USE" \
        --query 'build.id' \
        --output text)
    
    echo "CodeBuild started with ID: $BUILD_ID"
    echo "Waiting for build to complete..."
    
    # Wait for build to complete
    while true; do
        BUILD_STATUS=$(aws codebuild batch-get-builds \
            --ids "$BUILD_ID" \
            --profile "$PROFILE_TO_USE" \
            --query 'builds[0].buildStatus' \
            --output text)
        
        case $BUILD_STATUS in
            SUCCEEDED)
                echo "✅ CodeBuild completed successfully!"
                break
                ;;
            FAILED|FAULT|STOPPED|TIMED_OUT)
                echo "❌ CodeBuild failed with status: $BUILD_STATUS"
                
                # Get build logs
                echo ""
                echo "Build logs:"
                aws logs get-log-events \
                    --log-group-name "/aws/codebuild/$CODEBUILD_PROJECT_NAME" \
                    --log-stream-name "$BUILD_ID" \
                    --profile "$PROFILE_TO_USE" \
                    --query 'events[*].message' \
                    --output text 2>/dev/null | tail -20
                
                exit 1
                ;;
            IN_PROGRESS)
                echo "  Build in progress... ($(date +%H:%M:%S))"
                sleep 10
                ;;
            *)
                echo "  Build status: $BUILD_STATUS ($(date +%H:%M:%S))"
                sleep 10
                ;;
        esac
    done
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    echo "Layer build completed using CodeBuild!"
else
    echo "Skipping layer build (--skip-build specified)"
fi

echo ""
echo "=== Deploying CloudFormation Stack ==="

# Deploy CloudFormation stack
aws cloudformation deploy \
    --profile "$PROFILE_TO_USE" \
    --template-file template.yaml \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --parameter-overrides \
        EnvironmentName="$ENVIRONMENT_NAME" \
        AppName="$APP_NAME" \
        PythonVersion="$PYTHON_VERSION" \
    --capabilities CAPABILITY_IAM \
    --tags \
        Environment="$ENVIRONMENT_NAME" \
        Purpose=LambdaLayer \
        ManagedBy=CloudFormation

echo "Lambda Layer deployment completed successfully!"

# Display stack outputs
echo ""
echo "=== Lambda Layer Information ==="
aws cloudformation describe-stacks \
    --profile "$PROFILE_TO_USE" \
    --stack-name "${APP_NAME}-${ENVIRONMENT}" \
    --query 'Stacks[0].Outputs[].{Key:OutputKey,Value:OutputValue,Description:Description}' \
    --output table

echo ""
echo "=== Usage Instructions ==="
echo "To use this layer in your Lambda functions, reference it using:"
echo ""
echo "CloudFormation Template:"
echo "  Layers:"
echo "    - !ImportValue ${APP_NAME}-${ENVIRONMENT}-LayerArnWithVersion"
echo ""
echo "AWS CLI:"
echo "  LAYER_ARN=\$(aws cloudformation describe-stacks --stack-name ${APP_NAME}-${ENVIRONMENT} --query 'Stacks[0].Outputs[?OutputKey==\`LayerArnWithVersion\`].OutputValue' --output text --profile $PROFILE_TO_USE)"
