#!/usr/bin/env bash

set -e

usage() {
    echo "Creates an initial RDS snapshot for a given cohort."
    echo "The randomly generated password will be stored in EC2 Parameter Store"
    echo "This snapshot can be used in Terraform to initialise RDS clusters without having to specify a password."
    echo "Note: This script assumes the existance of the accounts default VPC"
    echo "Usage:"
    echo "./bootstrap_rds_db.sh COHORT DB_NAME"
    echo "For example:"
    echo "./bootstrap_rds_db.sh london-summer-2018 airflow"
}

if [  $# -le 1 ]; then
    usage
    exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "No AWS region configured, consider setting the AWS_DEFAULT_REGION environment variable."
    exit 1
fi

COHORT=$1
DB_NAME=$2

DB_INSTANCE_ID="${COHORT}-${DB_NAME}-bootstrap"
DB_SNAPSHOT_ID="${COHORT}-${DB_NAME}"

DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
DB_PASSWORD_PARAM_NAME="${DB_SNAPSHOT_ID}-password"

echo "creating bootstrap RDS instance ${DB_INSTANCE_ID}"
aws rds create-db-instance \
    --db-name ${DB_NAME} \
    --db-instance-identifier ${DB_INSTANCE_ID} \
    --db-subnet-group-name ${COHORT}-bootstrap-db-subnet-group \
    --allocated-storage 30 \
    --db-instance-class db.t2.micro \
    --storage-type gp2 \
    --engine postgres \
    --master-username ${DB_NAME} \
    --master-user-password ${DB_PASSWORD} > /dev/null
echo "waiting..."
aws rds wait db-instance-available --db-instance-identifier ${DB_INSTANCE_ID}

echo "snapshotting & destroying..."
aws rds delete-db-instance --db-instance-identifier ${DB_INSTANCE_ID} --final-db-snapshot-identifier ${DB_SNAPSHOT_ID} > /dev/null
aws rds wait db-instance-deleted --db-instance-identifier ${DB_INSTANCE_ID}


echo "saving password to parameter store..."
aws ssm put-parameter \
    --name "${DB_PASSWORD_PARAM_NAME}" \
    --description "Password for ${DB_SNAPSHOT_ID} RDS snapshot" \
    --value "${DB_PASSWORD}" \
    --type SecureString \
    --overwrite

echo "New RDS snapshot available: ${DB_SNAPSHOT_ID}"
echo "Password saved to parameter store under: ${DB_PASSWORD_PARAM_NAME}"
