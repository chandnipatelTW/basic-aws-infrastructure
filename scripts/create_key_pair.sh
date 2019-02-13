#!/usr/bin/env bash

usage() {
    echo "Create an EC2 keypair for a given cohort and persist private half in Parameter Store "
    echo "./create_key_pair.sh COHORT_NAME"
    echo "For example"
    echo "./create_key_pair.sh london-summer-2018"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "No AWS region configured, consider setting the AWS_DEFAULT_REGION environment variable."
    exit 1
fi

COHORT=$1
KEY_NAME="tw-dataeng-${COHORT}"

KEY_VALUE=$(aws ec2 create-key-pair \
    --key-name $KEY_NAME --query 'KeyMaterial' \
    --output text)

aws ssm put-parameter \
    --name $KEY_NAME \
    --description "Private key for ${COHORT}" \
    --value "$KEY_VALUE" \
    --type SecureString \
    --overwrite

