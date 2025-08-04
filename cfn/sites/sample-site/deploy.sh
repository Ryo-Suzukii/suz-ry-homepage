#!/bin/bash

set -e

# Usage: ./deploy.sh <environment> [profile=<aws-profile>] [--skip-build]
# Example: ./deploy.sh dev                    # Build and upload files
# Example: ./deploy.sh dev --skip-build       # Upload files only (skip build)
# Example: ./deploy.sh dev profile=my-profile

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
    echo "Example: $0 dev                    # Build and upload files"
    echo "Example: $0 dev --skip-build       # Upload files only (skip build)"
    echo "Example: $0 dev profile=my-profile"
    exit 1
fi

# Prepare profile argument for file-upload script
PROFILE_ARG=""
if [ -n "$CUSTOM_PROFILE" ]; then
    PROFILE_ARG="profile=$CUSTOM_PROFILE"
fi

SKIP_BUILD_ARG=""
if [ "$SKIP_BUILD" = true ]; then
    SKIP_BUILD_ARG="--skip-build"
fi

echo "Deploying React application for environment: $ENVIRONMENT"
echo "========================================="

# Execute file upload (which includes build unless --skip-build is specified)
./file-upload.sh "$ENVIRONMENT" $PROFILE_ARG $SKIP_BUILD_ARG

echo "========================================="
echo "Deployment completed successfully!"