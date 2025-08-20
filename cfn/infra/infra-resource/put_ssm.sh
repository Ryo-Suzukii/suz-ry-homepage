#!/bin/bash

function put() {
    echo "$GENVS" | jq

    put_ssm "$@"
}

PROJECT_BASE=$(git rev-parse --show-toplevel)

if [ -z "$INFRA_BASE" ]; then
    INFRA_BASE=$PROJECT_BASE
fi

# shellcheck source=/dev/null
. "$INFRA_BASE"/env_params/env_common.sh

check_and_set_env "$1" "$2"
put "${@:3}"
