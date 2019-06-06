#!/bin/bash
if [[ -z $1 ]]; then
    echo "Usage: $0 SERVERNAME"
    echo "Generates a new static client certificate"
    exit 1
fi

# Make the server cert
echo "# Making server certificate"
cat config/csr.json | sed -e s/%COMMONNAME%/$1/g | \
cfssl gencert -ca certs/ca.pem -ca-key certs/ca-key.pem \
    -config=config/profiles.json \
    -profile="server" \
    -hostname="$1" - |\
    cfssljson -bare certs/$1
