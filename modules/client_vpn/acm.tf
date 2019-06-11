data "aws_acm_certificate" "root" {
  domain      = "${var.cohort}.training"
  types       = ["IMPORTED"]
  most_recent = true
}

data "aws_acm_certificate" "server" {
  domain      = "openvpn.${var.cohort}.training"
  types       = ["IMPORTED"]
  most_recent = true
}
