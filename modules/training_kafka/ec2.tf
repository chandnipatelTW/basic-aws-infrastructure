resource "aws_instance" "kafka" {
  ami                    = "${data.aws_ami.training_kafka.image_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.kafka.id}"]
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.ec2_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.kafka.name}"
  user_data = <<-EOT
    #!/bin/bash

    function replace_property_value()
    {
      property_file=$1
      property_name=$2
      property_value=$3

      sed -i -r "s/^$${property_name}=(.*)$/$${property_name}=$${property_value}/g" $${property_file}
    }

    set -e

    device_name="${var.data_device_name}"
    dir_path="${var.data_dir}"
    owner="cp-kafka"
    owner_group="confluent"
    kafka_data_dir="$${dir_path}/kafka"
    zookeeper_data_dir="$${dir_path}/zookeeper"

    mkfs -t xfs $${device_name}

    mkdir $${dir_path}

    cp /etc/fstab /etc/fstab.orig

    echo "UUID=$(blkid $${device_name} -o value | head -n 1)  $${dir_path}  xfs  defaults,nofail  0  2" | tee -a /etc/fstab

    mount -a

    if [[ $? -eq 0 ]]
    then
      rm /etc/fstab.orig
    else
      rm /etc/fstab
      mv /etc/fstab.orig /etc/fstab
    fi

    chown $${owner}:$${owner_group} $${dir_path}

    mkdir -p "$${kafka_data_dir}"
    mkdir -p "$${zookeeper_data_dir}"

    replace_property_value /etc/kafka/server.properties "log.dirs" "$${kafka_data_dir}"
    replace_property_value /etc/kafka/zookeeper.properties "dataDir" "$${zookeeper_data_dir}"

    EOT

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "kafka-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_ebs_volume" "kafka" {
  availability_zone = "${var.aws_region}a"
  size              = "${var.data_volume_size}"
  type              = "${var.data_volume_type}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "kafka-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_volume_attachment" "kafka" {
  device_name = "${var.data_device_name}"
  volume_id   = "${aws_ebs_volume.kafka.id}"
  instance_id = "${aws_instance.kafka.id}"

  provisioner "remote-exec" {
    when   = "destroy"
    inline = ["umount ${var.data_dir}"]
  }
}
