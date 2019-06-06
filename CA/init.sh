#!/bin/bash
# Initialize an OpenVPN CA
if ! which cfssl &>/dev/null; then
    echo "You need cfssl installed before you can continue"
    exit 1
fi

# Requires cfssl
echo "# Making certs directory"
mkdir -p certs

# Make the CA
echo "# Making CA certificate"
cfssl genkey --initca config/ca.json | cfssljson -bare certs/ca

