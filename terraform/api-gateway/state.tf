# Terraform state lookup for Lambda authoriser
data "terraform_remote_state" "lambda_authoriser" {
  backend = "s3"
  config = {
    bucket = "si-iac-terraform-state-store"
    key    = "${var.environment}/lambda-iac/authoriser/terraform.tfstate"
    region = var.region
  }
}

# Terraform state lookup for Lambda s3-files
data "terraform_remote_state" "lambda_s3_files" {
  backend = "s3"
  config = {
    bucket = "si-iac-terraform-state-store"
    key    = "${var.environment}/lambda-iac/s3-files/terraform.tfstate"
    region = var.region
  }
}

# Terraform state lookup for IAM roles
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "si-iac-terraform-state-store"
    key    = "${var.environment}/iam/terraform.tfstate"
    region = var.region
  }
}