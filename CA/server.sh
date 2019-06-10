#!/bin/bash
set -eu -o pipefail

CN=openvpn.${TRAINING_COHORT}.training

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
