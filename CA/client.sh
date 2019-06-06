#!/bin/bash
# Make a new client
if [[ -z $1 ]]; then
    echo "Usage: $0 CLIENTNAME"
    echo "Generates a new static client certificate"
    exit 1
fi

echo "# Making client certificate"
cat config/csr.json | sed -e s/%COMMONNAME%/$1/g | \
    cfssl gencert -ca certs/ca.pem -ca-key certs/ca-key.pem \
    -config="config/profiles.json" \
    -profile="client" \
    -hostname="$1" - |\
    cfssljson -bare "certs/$1"
