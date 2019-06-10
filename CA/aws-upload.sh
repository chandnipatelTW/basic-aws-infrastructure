#!/usr/bin/env bash
set -eu -o pipefail

aws acm import-certificate \
    --certificate file://certs/${TRAINING_COHORT}-root.pem \
    --private-key file://certs/${TRAINING_COHORT}-root-key.pem \
    --region=${AWS_DEFAULT_REGION}

aws acm import-certificate \
    --certificate file://certs/openvpn.${TRAINING_COHORT}.training.pem \
    --private-key file://certs/openvpn.${TRAINING_COHORT}.training-key.pem \
    --certificate-chain file://certs/${TRAINING_COHORT}-root.pem \
    --region=${AWS_DEFAULT_REGION}