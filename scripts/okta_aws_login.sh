#!/usr/bin/env bash

usage() {
    echo "Obtain temporary AWS credentials using Okta:"
    echo "source ./okta_aws_login.sh OKTA_SERVER APP_ID USERNAME"
    echo "For example:"
    echo "source ./okta_aws_login.sh my.okta.server.com abcdefg123456789xyz ripley@example.com"
}

if [  $# -le 2 ]; then
    usage
else
    OKTA_SERVER=$1
    APP_ID=$2
    USER_NAME=$3
    OKTA_VENV=${OKTA_VENV:-/okta_venv/bin/activate}
    SESSION_NAME="cli-okta-session"

    source $OKTA_VENV
    oktaauth \
        --username $USER_NAME \
        --server $OKTA_SERVER \
        --apptype amazon_aws \
        --appid $APP_ID |
        aws_role_credentials saml --profile $SESSION_NAME

    export AWS_PROFILE=$SESSION_NAME
fi
