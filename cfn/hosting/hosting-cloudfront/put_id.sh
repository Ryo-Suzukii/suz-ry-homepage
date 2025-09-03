#!/bin/bash

function put_id() {
    echo "$GENVS" | jq

    local _ID
    _ID=$(get_cfn_export "${EnvironmentName:?}"-"${AppName:?}"-CloudFront)
    put_ssm distribution-id "$_ID" ap-northeast-1
}

PROJECT_BASE=$(git rev-parse --show-toplevel)

if [ -z "$INFRA_BASE" ]; then
    INFRA_BASE=$PROJECT_BASE
fi

# shellcheck source=/dev/null
. "$INFRA_BASE"/env_params/env_common.sh

check_and_set_env "$@"
put_id
