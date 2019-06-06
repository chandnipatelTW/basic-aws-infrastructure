data "aws_ami" "training_kafka" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["data-eng-kafka-training-*"]
  }
}
