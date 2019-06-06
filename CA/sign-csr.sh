#!/bin/bash
# Make a new client
if [[ -z $1 ]]; then
    echo "Usage: $0 CSR_file_name.csr"
    echo "Generates a new client certificate"
    exit 1
fi

HOST=$(basename $1 .csr)

echo "# Signing client certificate"
cfssl sign -ca certs/ca.pem -ca-key certs/ca-key.pem -csr=$1 \
    -config="config/profiles.json" \
    -profile="client" |\
    cfssljson -bare "certs/$HOST"
