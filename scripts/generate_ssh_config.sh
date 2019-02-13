#!/usr/bin/env bash

set -e

usage() {
    echo "Generate an ssh configuration to simplify connecting to the training environment"
    echo "./generate_ssh_config COHORT"
    echo "For example:"
    echo "./generate_ssh_config.sh london-summer-2018"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

COHORT=$1

CONFIG_FILE=${HOME}/.ssh/config

BASTION_IP=$(./scripts/run_terraform.sh \
    $COHORT bastion \
    output bastion_ip_address)

KEY_NAME="tw-dataeng-${COHORT}"
PRIVATE_KEY_FILE=$HOME/.ssh/$KEY_NAME

cat >> $CONFIG_FILE << EOF
Host bastion *.${COHORT}.training
    IdentityFile ${PRIVATE_KEY_FILE}

Host emr-master.${COHORT}.training
    User hadoop

Host *.${COHORT}.training !bastion.${COHORT}.training
    User ec2-user
    ForwardAgent yes
    ProxyCommand ssh bastion.${COHORT}.training -W %h:%p 2>/dev/null

Host bastion.${COHORT}.training
    User ec2-user
    HostName ${BASTION_IP}
    DynamicForward 6789

EOF

echo appended configuration to "${CONFIG_FILE}"
