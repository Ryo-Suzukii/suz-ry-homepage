#!/bin/bash

PROJECT_BASE=$(git rev-parse --show-toplevel)

if [ -z "$INFRA_BASE" ]; then
    INFRA_BASE=$PROJECT_BASE
fi

# shellcheck source=/dev/null
. "$INFRA_BASE"/env_params/env_common.sh

check_and_set_env "$@"
deploy_pipeline_s3 \
    "$INFRA_BASE"/template/architectures/arm64/std3.0/pipeline_html.yaml \
    "${EnvironmentName:?}"-hosting-bucket-"${Region:?}" \
    /"$EnvironmentName"/hosting-cloudfront/distribution-id
