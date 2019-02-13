locals {
  common_tags = {
    Automation = "terraform"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
