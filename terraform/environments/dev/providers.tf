terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "petclinic-tf-state-4becead5"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"
  }
}