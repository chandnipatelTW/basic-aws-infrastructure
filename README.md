This repo contains automation to build a standalone environment for data engineering training.

# Setting up a new Account

## 1) Configuring your local environment

### Dependencies

Running the following command from the root of the project repo
will launch a locally running Docker container with all required
dependencies and place you inside a shell session.

```
docker-compose run --rm infrabox
```

Inside the container, the contents of this repo will be available under `/project`.

### Authenticating with AWS

If are using an Okta federated AWS account,
you will need to obtain a temporary set of AWS credentials.

You can obtain temporary credentials by sourcing `./scripts/okta_aws_login.sh`.
If you need help determining what parameters to use, please contact your local Okta administrator.

```
source ./scripts/okta_aws_login.sh myserver.okta.com abcdefg123456789xyz ripley@example.com
```

If you need to then switch into another role, this can be achieved with the AWS CLI.
However, sourcing the `./scripts/assume_role.sh` script can make this easier.

```
source ./scripts/assume_role.sh myrole
```

If you want to see the current identity you are autheticated as, invoke the AWS CLI:

```
aws sts get-caller-identity
```

### Setting Cohort and Region

Set the following environment variables:

- `AWS_DEFAULT_REGION` to the region you would like to create resources in
- `TRAINING_COHORT` to the name of the current training cohort you are running.

For example:

```
export AWS_DEFAULT_REGION=us-east-2
export TRAINING_COHORT=chicago-fall-2018
```

## 2) Preliminary Bootstraping

### Creating a bucket for Terraform state

Invoke `.scripts/create_tf_state_bucket.sh` to create a bucket for holding terraform state.


```
./scripts/create_tf_state_bucket.sh $TRAINING_COHORT
```

## Creating Client VPN certs

### Init the CA

```bash
cd CA
./manage.sh init && ./manage.sh server
```

### Import certs to AWS

```bash
./aws-upload.sh
```

### Make a client cert
```bash
./manage.sh client cpatel
```

This will generate 2 files: `certs/cpatel.${TRAINING_COHORT}.training.pem` and `certs/cpatel.${TRAINING_COHORT}.training-key.pem`

### Creating a EC2 keypair

If we were to use terraform to manage ec2 ssh keypairs, there would be the risk that the
private key would get stored insecurely in the Terraform state files. Instead, we can
create our keys outside of terraform, and securely store them in EC2 parameter store

This can be achieved with the `./scripts/create_key_pair.sh` script.

```
./scripts/create_key_pair.sh $TRAINING_COHORT
```

### Creating an initial RDS snapshot for Airflow

As with the EC2 keypair, configuring the password for the RDS Postgresql database
used by airflow is best done outside terraform. This is achieved by creating an initial
blank database snapshot with the desired password which can then be used by terraform
to build the RDS cluster.

The password is saved in Parameter store for future use.

```
./scripts/bootstrap_rds.sh $TRAINING_COHORT airflow
```

### Building an AMI for Kafka

```
./scripts/build_ami.sh training_kafka
```

### Building an AMI for Ingester

```
./scripts/build_ami.sh training_ingester
```


## 3) Building Terraform components

The AWS resources that comprise the training environment are automated with Terraform.
This automation is split up into several components, each concerned with building a
particular section of the environment.

Using the provided terraform wrapper `./scripts/run_terraform.sh`, invoke each component
in the following order. Remember to ensure to configure `AWS_DEFAULT_REGION` to the
desired AWS region.

```
./scripts/run_terraform.sh $TRAINING_COHORT base_networking apply
./scripts/run_terraform.sh $TRAINING_COHORT bastion apply
./scripts/run_terraform.sh $TRAINING_COHORT training_bucket apply
./scripts/run_terraform.sh $TRAINING_COHORT training_emr_cluster apply
./scripts/run_terraform.sh $TRAINING_COHORT training_kafka apply
./scripts/run_terraform.sh $TRAINING_COHORT ingester apply
./scripts/run_terraform.sh $TRAINING_COHORT monitoring_dashboard apply
```

## 4) Connecting to the environment

### Obtaining SSH private key

Confirm that you have a .ssh folder in your user (~) directory. Or you can just run the command to create the directory as required:

```
mkdir -p ~/.ssh/
```

Download from EC2 parameter store:

```
./scripts/get_key_pair.sh $TRAINING_COHORT
```

### Configuring SSH

Generate ssh config:

```
./scripts/generate_ssh_config.sh $TRAINING_COHORT
```

The following SSH commands should now work:

- `ssh bastion.$TRAINING_COHORT.training`
- `ssh emr-master.$TRAINING_COHORT.training`

### Configure proxy to access web user interaces

Run `ssh bastion.chicago-fall-2018.training` and leave the connection running.
This will create a SOCKS proxy running on localhost 6789

In Firefox you should now be able to configure proxy settings for `*.chicago-fall-2018.training` and `*.compute.internal` to use this. SwitchyOmega is a good extension for Chrome.
Ensure that the proxy DNS option is enabled.

Then you should be able to see the following resources:

| Resource | Link |
| -------- | ---- |
|YARN ResourceManager |	http://emr-master.chicago-fall-2018.training:8088/ |
|Hadoop HDFS NameNode |	http://emr-master.chicago-fall-2018.training:50070/ |
|Spark HistoryServer	| http://emr-master.chicago-fall-2018.training:18080/ |
|Zeppelin	| http://emr-master.chicago-fall-2018.training:8890/ |
|Hue	| http://emr-master.chicago-fall-2018.training:8888/ |
|Ganglia | http://emr-master.chicago-fall-2018.training/ganglia/ |

