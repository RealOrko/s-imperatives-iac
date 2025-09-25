# Terrform state lookup for groups/roles/policies
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "si-iac-terraform-state-store"
    key    = "${var.environment}/iam/terraform.tfstate"
    region = "${var.region}"
  }
}