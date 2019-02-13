#!/usr/bin/env bash

usage() {
    echo "Run a Terraform command for a particular component for a given cohort:"
    echo "./run_terraform.sh COHORT COMPONENT COMMAND"
    echo "For example:"
    echo "./run_terraform.sh london-summer-2018 base_networking apply"
}

if [  $# -le 2 ]; then
    usage
    exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "No AWS region configured, consider setting the AWS_DEFAULT_REGION environment variable."
    exit 1
fi

COHORT_NAME=$1
shift
COMPONENT_NAME=$1
shift
TF_ACTION=$1
shift
TF_CMD=$@

DEFAULT_BUCKET_NAME="tw-dataeng-$COHORT_NAME-tfstate"
BUCKET_NAME=${TF_STATE_BUCKET:-$DEFAULT_BUCKET_NAME}
COMPONENT_DIR=${TF_COMPONENT_DIR:-components}

TF_VAR_ARGS=""
if [[ "$TF_ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    TF_VAR_ARGS="-var cohort=${COHORT_NAME} \
                 -var aws_region=${AWS_DEFAULT_REGION}"
fi

pushd $COMPONENT_DIR/$COMPONENT_NAME > /dev/null

terraform init \
        -backend-config="key=${COMPONENT_NAME}.tfstate" \
        -backend-config="bucket=${BUCKET_NAME}" \
        -backend-config="region=${AWS_DEFAULT_REGION}" >&2

terraform $TF_ACTION $TF_VAR_ARGS $TF_CMD

popd > /dev/null
