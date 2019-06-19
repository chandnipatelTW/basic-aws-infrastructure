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

output_client_config ()
{
    ensure_ca_init
    CN=${1}.${TRAINING_COHORT}.training
    : ${AWS_DEFAULT_REGION:?"Variable is required."}
    : ${ENDPOINT:?"Variable is required, this is the AWS id of the client VPN endpoint, eg cvpn-endpoint-09105dfced0d9f596 ."}
    CA=$(cat certs/${TRAINING_COHORT}-root.pem)
    CERT=$(cat certs/${CN}.pem)
    KEY=$(cat certs/${CN}-key.pem)
    aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id $ENDPOINT --output text>config/$ENDPOINT.ovpn
    sed -e s/%ENDPOINT%/${ENDPOINT}/g \
        -e s/%REGION%/${AWS_DEFAULT_REGION}/g \
        < config/$ENDPOINT.ovpn > certs/${CN}.ovpn
    cat << EOF >> certs/${CN}.ovpn
<cert>
${CERT}
</cert>
<key>
${KEY}
</key>
EOF
    rm config/$ENDPOINT.ovpn
    echo "Success! openvpn config file created at certs/${CN}.ovpn"
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

usage ()
{
    echo "init   - create a new CA"
    echo "server - create AWS client VPN server certs"
    echo "client <client name> - create a client connection cert"
    echo "upload - upload the CA and server certs to AWS"
    echo "client_config <client name> - export openvpn config file"
    exit 1
}

CMD=${1:-usage}

case ${CMD} in
    init) init_ca ;;
    server) server_cert ;;
    client) client_cert ${2} ;;
    upload) aws_import ;;
    client_config) output_client_config ${2} ;;
    *) usage ;;
esac


