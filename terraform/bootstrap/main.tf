terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_id" "uuid" {
  byte_length = 4
}

provider "aws" { region = var.region }

resource "aws_s3_bucket" "tf_state" {
  bucket = "petclinic-tf-state-${random_id.uuid.hex}"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}