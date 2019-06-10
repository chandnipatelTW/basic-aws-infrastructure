#!/usr/bin/env bash
set -eu -o pipefail

ensure_basic_setup ()
{
    if ! cfssl version > /dev/null ; then
        echo "Please install cfssl"
        exit 1
    fi

    if [[ ! -d certs ]] ; then
        echo "Making certs directory"
        mkdir -p certs
    fi
    : ${TRAINING_COHORT:?"Variable is required."}
}

ensure_ca_init ()
{
    ensure_basic_setup
    if [[ ! -f certs/${TRAINING_COHORT}-root.pem ]] ; then
        echo No CA root found, please run $0 init
        exit 1
    fi
}

init_ca ()
{
    ensure_basic_setup
    CN=${TRAINING_COHORT}.training
    echo "Making CA certificate for ${CN}"

    sed -e s/%COMMONNAME%/${CN}/g < config/ca.json | \
        cfssl genkey --initca - | \
        cfssljson -bare certs/${TRAINING_COHORT}-root
}

server_cert ()
{
    ensure_ca_init
    CN=openvpn.${TRAINING_COHORT}.training
    echo "Making server certificate"
    sed -e s/%COMMONNAME%/${CN}/g < config/csr.json | \
     cfssl gencert \
        -ca certs/${TRAINING_COHORT}-root.pem \
        -ca-key certs/${TRAINING_COHORT}-root-key.pem \
        -config config/profiles.json \
        -profile server \
        -hostname ${CN} - | \
     cfssljson -bare certs/${CN}
}

aws_import ()
{
    ensure_ca_init
    : ${AWS_DEFAULT_REGION:?"Variable is required."}
    aws acm import-certificate \
        --certificate file://certs/${TRAINING_COHORT}-root.pem \
        --private-key file://certs/${TRAINING_COHORT}-root-key.pem \
        --region=${AWS_DEFAULT_REGION}
    aws acm import-certificate \
        --certificate file://certs/openvpn.${TRAINING_COHORT}.training.pem \
        --private-key file://certs/openvpn.${TRAINING_COHORT}.training-key.pem \
        --certificate-chain file://certs/${TRAINING_COHORT}-root.pem \
        --region=${AWS_DEFAULT_REGION}
}

client_cert ()
{
    ensure_ca_init
    CN=${1}.${TRAINING_COHORT}.training
    echo "Making client certificate"
    sed -e s/%COMMONNAME%/${CN}/g < config/csr.json | \
        cfssl gencert \
            -ca certs/${TRAINING_COHORT}-root.pem \
            -ca-key certs/${TRAINING_COHORT}-root-key.pem \
            -config config/profiles.json \
            -profile client \
            -hostname ${CN} - |\
        cfssljson -bare certs/${CN}
}

usage ()
{
    echo "init - create a new CA"
    echo "server - create AWS client VPN server certs"
    echo "client <client name> - create a client connection cert"
    echo "upload - Upload the CA and server certs to AWS"
    exit 1
}

CMD=${1:-usage}

case ${CMD} in
    init) init_ca ;;
    server) server_cert ;;
    client) client_cert ${2} ;;
    usage) usage ;;
    upload) aws_import ;;
esac


