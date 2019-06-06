resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.amazon_linux_2.image_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.ec2_key_pair}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "bastion-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "bastion-eip-${var.deployment_identifier}"
    )
  )}"
}
