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

### Creating VPN certs

#### Init the CA

```bash
cd CA
./manage.sh init && ./manage.sh server
```

This will generate Root and Server cert that then will be uploaded to AWS and later will be used to generate client certs to connect to the VPN.


#### Import certs to AWS

```bash
./manage.sh upload
```

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
./scripts/run_terraform.sh $TRAINING_COHORT client_vpn apply
```

## 4) Connecting to the environment

### Preparing AWS Client VPN 

Currently is not possible to automate some VPN configs with Terraform, so for now you need to do it manually.

Go to AWS Management Console > VPC > Client VPN and select the VPN Endpoint that Terraform just created

#### Configure Security Groups:

With the Client VPN Endpoint Selected, go to Security Groups Tab, choose the only VPC and press Apply Security Groups.

Select the security groups that the VPN needs to access to EMR, Kafka, Ingester, Airflow. And press "Apply Security Groups"

#### Add user Authorization Ingress:

With the Client VPN Endpoint Selected, go to Authorization Tab, choose the only VPC and press Authorize Ingress

Add `0.0.0.0/0` as Destination network to enable  and Allow access to all users. Press "Add Authorization Rule".

#### Add route table to client vpn with publics subnets:

With the Client VPN Endpoint Selected, go to Authorization Tab.

Press Create Route.

`0.0.0.0/0` as Route destination, then select one of the public subnets. And press "Create Route"

Repeat for the other two public subnets.

### Using VPN

#### Make a client certs

With the same CA that created the root, server and client certs you need to create client certs

```bash
cd CA
./manage.sh client cpatel
```

This will generate 2 files: `certs/cpatel.${TRAINING_COHORT}.training.pem` and `certs/cpatel.${TRAINING_COHORT}.training-key.pem`

#### Create a client config file
With the root, server and client certs you will generate now openvpn config files (one for each client).

Export a variable with the *Client VPN EndpointID* that you'll get as a result of clien_vpn component creation in Terraform. Also you can find it in AWS > VPC Dashboard > Virtual Private Network (VPN) > Client VPN Endpoints. eg: cvpn-endpoint-0d4b52bbe4393d9f1

```
export ENDPOINT=YourEndpointID
```

Next run this script to get the VPN client config file.

```bash
./manage.sh client_config clientname
```

This will generate a file like: `certs/clientname.${TRAINING_COHORT}.training.ovpn`


Download [Viscosity VPN Client](https://www.sparklabs.com/viscosity/) and import the *.ovpn file there. Click connect :D


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

### All set!

When connected to the VPN, the following SSH commands should work:

- `ssh -i ~/.ssh/tw-dataeng-$TRAINING_COHORT hadoop@emr-master.$TRAINING_COHORT.training`
- `ssh -i ~/.ssh/tw-dataeng-$TRAINING_COHORT ec2-user@kafka.$TRAINING_COHORT.training`

Also, you should be able to see the following resources:

| Resource | Link |
| -------- | ---- |
|YARN ResourceManager |	http://emr-master.$TRAINING_COHORT.training:8088/ |
|Hadoop HDFS NameNode |	http://emr-master.$TRAINING_COHORT.training:50070/ |
|Spark HistoryServer	| http://emr-master.$TRAINING_COHORT.training:18080/ |
|Zeppelin	| http://emr-master.$TRAINING_COHORT.training:8890/ |
|Hue	| http://emr-master.$TRAINING_COHORT.training:8888/ |
|Ganglia | http://emr-master.$TRAINING_COHORT.training/ganglia/ |

