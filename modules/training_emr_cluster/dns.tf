resource "aws_route53_record" "emr_master" {
  zone_id = "${var.dns_zone_id}"
  name    = "emr-master"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_emr_cluster.training_cluster.master_public_dns}"]
}
