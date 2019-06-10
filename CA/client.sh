#!/bin/bash
set -eu -o pipefail

if [[ -z $1 ]]; then
    echo "Usage: $0 CLIENTNAME"
    echo "Generates a new static client certificate"
    exit 1
else
    CN=${1}.${TRAINING_COHORT}.training
fi

echo "Making client certificate"
sed -e s/%COMMONNAME%/${CN}/g < config/csr.json | \
    cfssl gencert -ca certs/ca.pem -ca-key certs/ca-key.pem \
    -config="config/profiles.json" \
    -profile="client" \
    -hostname="${CN}" - |\
    cfssljson -bare "certs/${CN}"
