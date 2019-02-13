#!/usr/bin/env bash

usage() {
    echo "Download EC2 keypair for a given cohort"
    echo "./get_key_pair.sh COHORT_NAME"
    echo "For example"
    echo "./get_key_pair.sh london-summer-2018"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

COHORT=$1
KEY_NAME="tw-dataeng-${COHORT}"
PRIVATE_KEY_FILE=$HOME/.ssh/$KEY_NAME

aws ssm get-parameters \
    --names $KEY_NAME \
    --with-decryption \
    --output text \
    --query 'Parameters[0].Value' \
    > $PRIVATE_KEY_FILE

chmod 400 $PRIVATE_KEY_FILE

echo "Written key ${PRIVATE_KEY_FILE}"
