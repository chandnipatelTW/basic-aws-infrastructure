data "aws_ami" "training_ingester" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["data-eng-ingester-training-*"]
  }
}
