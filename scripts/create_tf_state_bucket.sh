#!/usr/bin/env bash

usage() {
    echo "Create an S3 bucket for managing teraform state for a given cohort:"
    echo "./create_tf_state_bucket.sh COHORT"
    echo "For example:"
    echo "./create_tf_state_bucket.sh london-summer-2018"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "No AWS region configured, consider setting the AWS_DEFAULT_REGION environment variable."
    exit 1
fi

BUCKET_NAME="tw-dataeng-${1}-tfstate"

aws s3 mb s3://$BUCKET_NAME
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled
