#!/bin/bash

function create_keypair() {
    openssl genrsa -out private_key.pem 2048
    openssl rsa -pubout -in private_key.pem -out public_key.pem >/dev/null 2>&1
}

function put_keypair() {
    echo "$GENVS" | jq

    local _PRIVATE
    _PRIVATE=$(cat private_key.pem)
    local _PUBLIC
    _PUBLIC=$(cat public_key.pem)
    rm private_key.pem public_key.pem

    put_ssm rsa/private "$_PRIVATE" ap-northeast-1 --secure
    put_ssm rsa/public "$_PUBLIC"
}

PROJECT_BASE=$(git rev-parse --show-toplevel)

if [ -z "$INFRA_BASE" ]; then
    INFRA_BASE=$PROJECT_BASE
fi

# shellcheck source=/dev/null
. "$INFRA_BASE"/env_params/env_common.sh

check_and_set_env "$@"
create_keypair
put_keypair
