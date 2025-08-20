#!/bin/bash

####################################################################################################
# Deploy
####################################################################################################
function check_and_set_env() {
    check_params "$@"

    GENVS='{}'

    local _JSON
    _JSON=$(jq . -c "$INFRA_BASE"/env_params/env.json)

    local _PROJECT
    _PROJECT=$(jq -nr --argjson json "$_JSON" '$json | .Exports.Project')
    _JSON=$(jq -cn --argjson json "$_JSON" --arg project "$_PROJECT" '$json | .Exports.Infra=$project')
    _JSON=$(jq -c --argjson json "$_JSON" '$json * .' "$PROJECT_BASE"/env_params/env.json)

    if [ -f "$ParamPathPrefix"/param_common.json ]; then
        _JSON=$(jq -c --argjson json "$_JSON" '$json * .' "$ParamPathPrefix"/param_common.json)
    fi
    set_env "$(jq -c --argjson json "$_JSON" '$json * .' "$ParamPathPrefix"/param_"$ParamEnvironment".json)"

    if [ -z "$(jq -nr --argjson env "$GENVS" '$env | .Exports.Planning // empty')" ]; then
        echo undefined Planning
        exit 1
    fi

    if [ -z "$(jq -nr --argjson env "$GENVS" '$env | .Exports.Project // empty')" ]; then
        echo undefined Project
        exit 1
    fi

    local _BASE
    _BASE='{
        "Exports": {"Profile": "'${ProfilePrefix:?}$ParamSuffixEnvironment'"},
        "Parameters": {
            "EnvironmentPrefix": "'$ParamPrefixEnvironment${Planning:?}'",
            "EnvironmentName": "'$ParamPrefixEnvironment${Project:?}'",
            "InfraName": "'$ParamPrefixEnvironment${Infra:?}'",
            "CategoryName": "'$(get_category_name)'",
            "AppName": "'$(get_app_name)'"
        }
    }'
    set_env "$(echo "$_BASE" | jq -c --argjson env "$GENVS" '. * $env')"
}

function deploy() {
    if [ "$ParamForceDeploy" == true ]; then
        add_env '{"Parameters":{"Version":"'"$(get_random_str)"'"}}'
    fi

    echo "$GENVS" | jq

    local _PARAMS
    _PARAMS=$(convert_env_str "$GENVS" Parameters)
    local _TAGS
    _TAGS=$(convert_env_str "$GENVS" Tags)

    if [ "$ParamS3Deploy" == true ]; then
        sam deploy \
            --stack-name "${EnvironmentName:?}"-"${AppName:?}" \
            --capabilities CAPABILITY_NAMED_IAM \
            --parameter-overrides "$_PARAMS" \
            --region "${DeployRegion:?}" \
            --profile "${Profile:?}" \
            --tags "$_TAGS" \
            --s3-bucket wni-"${InfraName:?}"-infra-cicd-"${Region:?}" \
            --s3-prefix artifact/"${EnvironmentName:?}"/"${AppName:?}"
    else
        sam deploy \
            --stack-name "${EnvironmentName:?}"-"${AppName:?}" \
            --capabilities CAPABILITY_NAMED_IAM \
            --parameter-overrides "$_PARAMS" \
            --region "${DeployRegion:?}" \
            --profile "${Profile:?}" \
            --tags "$_TAGS"
    fi
}

function deploy_pipeline() {
    local _TEMPLATE=$1
    if [ ! -f "$_TEMPLATE" ]; then
        echo no such file: "$_TEMPLATE"
        exit 1
    fi

    if [ $# -ge 2 ]; then
        add_env '{"Parameters":{"BaseImage":"'"$2"'"}}'
    fi

    local _JSON='{}'
    if [ -n "$SamVersion" ]; then
        _JSON=$(jq -cn --argjson json "$_JSON" --arg val "$SamVersion" '$json | .Parameters.SamVersion=$val')
    fi
    if [ -n "$CodeBuildType" ]; then
        _JSON=$(jq -cn --argjson json "$_JSON" --arg val "$CodeBuildType" '$json | .Parameters.CodeBuildType=$val')
    fi
    if [ -n "${CodeBuildComputeType}" ]; then
        _JSON=$(jq -cn --argjson json "$_JSON" --arg val "$CodeBuildComputeType" '$json | .Parameters.CodeBuildComputeType=$val')
    fi
    if [ -n "${CodeBuildImage}" ]; then
        _JSON=$(jq -cn --argjson json "$_JSON" --arg val "$CodeBuildImage" '$json | .Parameters.CodeBuildImage=$val')
    fi
    add_env "$_JSON"

    echo "$GENVS" | jq

    local _PARAMS
    _PARAMS=$(convert_env_str "$GENVS" Parameters)
    local _TAGS
    _TAGS=$(convert_env_str "$GENVS" Tags)

    sam deploy \
        --stack-name "${EnvironmentName:?}"-"${AppName:?}"-pipeline \
        --template-file "$_TEMPLATE" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides "$_PARAMS" \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}" \
        --tags "$_TAGS"
}

function deploy_pipeline_s3() {
    local _TEMPLATE=$1
    if [ ! -f "$_TEMPLATE" ]; then
        echo no such file: "$_TEMPLATE"
        exit 1
    fi

    add_env '{"Parameters":{"BucketName":"'"$2"'","DistributionId":"'"$3"'"}}'

    echo "$GENVS" | jq

    local _PARAMS
    _PARAMS=$(convert_env_str "$GENVS" Parameters)
    local _TAGS
    _TAGS=$(convert_env_str "$GENVS" Tags)

    sam deploy \
        --stack-name "${EnvironmentName:?}"-"${AppName:?}"-pipeline \
        --template-file "$_TEMPLATE" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides "$_PARAMS" \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}" \
        --tags "$_TAGS"
}

function upload_to_pipeline() {
    local _COPIED=0
    if [ ! -f buildspec.yaml ]; then
        cp "$1" buildspec.yaml
        _COPIED=1
    fi

    if [ ! -f buildspec.yaml ]; then
        echo no such file: buildspec.yaml
        exit 1
    fi

    echo "$GENVS" | jq

    jq -cn --argjson env "$GENVS" '$env | del(.Exports)' >cfn_params/param.json

    rm -rf .zip
    mkdir .zip
    zip \
        -r .zip/"${AppName:?}"_input.zip \
        cfn_params src ./*.yaml \
        -x \*__pycache__/\* \*/.\* \*tests/\* \*cov\*.xml \*pytest.ini >/dev/null 2>&1

    aws s3 cp \
        .zip/"${AppName:?}"_input.zip \
        s3://wni-"${InfraName:?}"-infra-cicd-"${Region:?}"/artifact/"${EnvironmentName:?}"/ \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}"

    rm -rf .zip
    rm cfn_params/param.json

    if [ $_COPIED == 1 ]; then
        rm buildspec.yaml
    fi
}

function upload_to_pipeline_s3() {
    local _COPIED=0
    if [ ! -f buildspec.yaml ]; then
        cp "$1" buildspec.yaml
        _COPIED=1
    fi

    if [ ! -f buildspec.yaml ]; then
        echo no such file: buildspec.yaml
        exit 1
    fi

    echo "$GENVS" | jq

    rm -rf .zip
    mkdir .zip
    zip .zip/"${AppName:?}"_input.zip ./*.yaml >/dev/null 2>&1 &&
        (cd src &&
            zip -ur ../.zip/"${AppName:?}"_input.zip \
                . -x \*node_modules/\* \*dist/\*) >/dev/null 2>&1

    aws s3 cp \
        .zip/"${AppName:?}"_input.zip \
        s3://wni-"${InfraName:?}"-infra-cicd-"${Region:?}"/artifact/"${EnvironmentName:?}"/ \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}"

    rm -rf .zip

    if [ $_COPIED == 1 ]; then
        rm buildspec.yaml
    fi
}

function sync() {
    echo "$GENVS" | jq

    local _PARAMS
    _PARAMS=$(convert_env_str "$GENVS" Parameters)
    local _TAGS
    _TAGS=$(convert_env_str "$GENVS" Tags)

    sam sync \
        --watch \
        --no-dependency-layer \
        --stack-name "${EnvironmentName:?}"-"${AppName:?}" \
        --parameter-overrides "$_PARAMS" \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}" \
        --tags "$_TAGS" \
        --s3-bucket wni-"${InfraName:?}"-infra-cicd-"${Region:?}" \
        --s3-prefix artifact/"${EnvironmentName:?}"/"${AppName:?}"

    rm -rf .aws-sam
}

####################################################################################################
# Utility
####################################################################################################
function get_cfn_export() {
    local _EXPORT
    _EXPORT=$(aws cloudformation list-exports \
        --region "${DeployRegion:?}" \
        --profile "${Profile:?}" \
        --query "Exports[?Name=='$1'].Value" \
        --output text)
    if [ -z "$_EXPORT" ]; then
        echo "$1" is not exist.
        exit 1
    fi
    echo "$_EXPORT"
}

function put_ssm() {
    local _ARGS
    _ARGS=$(jq -cn '$ARGS.positional' --args -- "$@")

    local _REGION
    _REGION=$(jq -nr --argjson args "$_ARGS" '$args | .[2] // empty | select(. | startswith("--") | not) // empty')
    if [ -z "$_REGION" ]; then
        _REGION=$DeployRegion
    fi

    local _TYPE="String"
    if [ "$(has_flag "$_ARGS" '"--secure"')" == true ]; then
        _TYPE="SecureString"
    fi

    local _TAGS
    _TAGS=$(convert_env_key_value_str "$GENVS" Tags)

    if [ "$(has_flag "$_ARGS" '"--overwrite"')" == true ]; then
        # shellcheck disable=SC2086
        aws ssm put-parameter \
            --name /"${EnvironmentName:?}"/"${AppName:?}"/"$1" \
            --value "$2" \
            --type "$_TYPE" \
            --region "$_REGION" \
            --profile "${Profile:?}" \
            --overwrite
    else
        # shellcheck disable=SC2086
        aws ssm put-parameter \
            --name /"${EnvironmentName:?}"/"${AppName:?}"/"$1" \
            --value "$2" \
            --type "$_TYPE" \
            --region "$_REGION" \
            --profile "${Profile:?}" \
            --tags $_TAGS
    fi
}

####################################################################################################
# Private
####################################################################################################
function set_env() {
    local _EXPS
    _EXPS=$(convert_env_str "$1" Exports)
    for el in ${_EXPS}; do
        # shellcheck disable=SC2163
        export "$el"
    done

    local _ENVS
    _ENVS=$(convert_env_str "$1" Parameters)
    for el in ${_ENVS}; do
        # shellcheck disable=SC2163
        export "$el"
    done

    add_env "$1"
}

function check_params() {
    if [ $# -lt 1 ]; then
        echo "need EnvironmentName[dev|stg|prd]"
        exit 1
    fi
    ParamEnvironment=$1

    ParamPrefixEnvironment=""
    ParamSuffixEnvironment=""
    if [ "$ParamEnvironment" = "prd" ]; then
        ParamPrefixEnvironment=""
        ParamSuffixEnvironment="_prd"
    elif [ "$ParamEnvironment" = "stg" ]; then
        ParamPrefixEnvironment="stg-"
        ParamSuffixEnvironment="_stg"
    elif [ "$ParamEnvironment" = "dev" ]; then
        ParamPrefixEnvironment="dev-"
        ParamSuffixEnvironment="_dev"
    else
        echo "need EnvironmentName[dev|stg|prd]"
        exit 1
    fi

    local _ARGS
    _ARGS=$(jq -cn '$ARGS.positional' --args -- "$@")

    ParamDirectory=$(jq -nr --argjson args "$_ARGS" '$args | .[1] // empty | select(. | startswith("--") | not) // empty')

    ParamPathPrefix="cfn_params"
    if [ -n "$ParamDirectory" ]; then
        ParamPathPrefix=cfn_params/"$ParamDirectory"
    fi

    if [ ! -f "$ParamPathPrefix"/param_"$ParamEnvironment".json ]; then
        echo no file: "$ParamPathPrefix"/param_"$ParamEnvironment".json
        exit 1
    fi

    ParamForceDeploy=$(has_flag "$_ARGS" '"--force"')
    export ParamForceDeploy

    ParamS3Deploy=$(has_flag "$_ARGS" '"--s3"')
    export ParamS3Deploy
}

function get_category_name() {
    basename "$(dirname "$(
        cd "$(dirname "$0")" || return
        pwd
    )")"
}

function get_app_name() {
    basename "$(
        cd "$(dirname "$0")" || return
        pwd
    )" | sed s/"$Project"-//
}

function convert_env_str() {
    jq -cn --argjson json "$1" '$json | if .'"$2"' then .'"$2"' else {} end' | jq -r 'to_entries | map("\(.key)=\(.value)") | join(" ")'
}

function convert_env_key_value_str() {
    jq -cn --argjson json "$1" '$json | if .'"$2"' then .'"$2"' else {} end' | jq -r 'to_entries | map("Key=\(.key),Value=\(.value)") | join(" ")'
}

function add_env() {
    GENVS=$(jq -cn --argjson env "$GENVS" --argjson json "$1" '$env * $json')
}

function has_flag() {
    jq -nr --argjson args "$1" '$args | if index('"$2"') != null then true else false end'
}

function get_random_str() {
    LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 10 | head -n 1
}
