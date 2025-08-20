#!/bin/bash

PROJECT_BASE=$(git rev-parse --show-toplevel)

if [ -z "$INFRA_BASE" ]; then
    INFRA_BASE=$PROJECT_BASE
fi

# shellcheck source=/dev/null
. "$INFRA_BASE"/env_params/env_common.sh

check_and_set_env "$@"
upload_to_pipeline "$INFRA_BASE"/template/runtimes/python3.13/buildspec_lambda_container.yaml
