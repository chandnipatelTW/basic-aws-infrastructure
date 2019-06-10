#!/bin/bash
set -eu -o pipefail
CN=${TRAINING_COHORT}.training

# Initialize an OpenVPN CA
if ! which cfssl &>/dev/null; then
    echo "You need cfssl installed before you can continue"
    echo "macOS: brew install cfssl"
    exit 1
fi

# Requires cfssl
if [[ ! -d certs ]] ; then
    echo "Making certs directory"
    mkdir -p certs
fi

# Make the CA
echo "Making CA certificate for ${CN}"

sed -e s/%COMMONNAME%/${CN}/g < config/ca.json | \
    cfssl genkey --initca - | \
    cfssljson -bare certs/${TRAINING_COHORT}-root