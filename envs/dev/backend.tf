terraform {
  backend "s3" {
    bucket         = "terraform-state-hameed-eks-platform"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-2"
    profile        = "hameed-admin"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}