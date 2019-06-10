#!/bin/bash
set -eu -o pipefail

if [[ -z $1 ]]; then
    echo "Usage: $0 SERVERNAME"
    echo "Generates an openvpn server certificate"
    exit 1
else
    CN=${1}.${TRAINING_COHORT}.training
fi



# Make the server cert
echo "Making server certificate"

sed -e s/%COMMONNAME%/${CN}/g < config/csr.json | \
 cfssl gencert \
    -ca certs/${TRAINING_COHORT}-root.pem \
    -ca-key certs/${TRAINING_COHORT}-root-key.pem \
    -config config/profiles.json \
    -profile server \
    -hostname ${CN} - | \
 cfssljson -bare certs/${CN}
