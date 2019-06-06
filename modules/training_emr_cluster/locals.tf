locals {
  cluster_name = "emr-training-${var.deployment_identifier}"
  common_tags = {
    Automation           = "terraform"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
