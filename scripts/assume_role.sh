#!/usr/bin/env bash

usage() {
    echo "Assume an IAM role in the currently authenticated account"
    echo "source ./assume_role.sh ROLE_NAME"
}

if [ $# -eq 0 ]; then
    usage
else
    ROLE_NAME=$1
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

    STS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name aws-cli-session)
    if [ $? -eq 0 ]; then
        export AWS_ACCESS_KEY_ID=$(echo $STS | jq -r .Credentials.AccessKeyId)
        export AWS_SECRET_ACCESS_KEY=$(echo $STS | jq -r .Credentials.SecretAccessKey)
        export AWS_SESSION_TOKEN=$(echo $STS | jq -r .Credentials.SessionToken)
    fi
fi
