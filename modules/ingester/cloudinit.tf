data "local_file" "ingester_dependencies" {
  filename = "${path.module}/scripts/dependencies.sh"
}

data "template_cloudinit_config" "ingester" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.local_file.ingester_dependencies.content}"
  }
}
