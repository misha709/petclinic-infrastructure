locals {
  bucket_suffix = "4becead5"
}

terraform {
  backend "s3" {
    bucket = "petclinic-tf-state-${local.bucket_suffix}"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"
  }
}