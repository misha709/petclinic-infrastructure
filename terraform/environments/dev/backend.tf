module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = "10.0.0.0/16"
  cluster_name = "petclinic-dev"

  public_subnets = {
    "subnet1" = { cidr = "10.0.1.0/24", availability_zone = "eu-west-1a" }
    "subnet2" = { cidr = "10.0.2.0/24", availability_zone = "eu-west-1b" }
  }

  private_subnets = {
    "subnet1" = { cidr = "10.0.10.0/24", availability_zone = "eu-west-1a" }
    "subnet2" = { cidr = "10.0.11.0/24", availability_zone = "eu-west-1b" }
  }

  tags = merge(var.project_tags, { Module = "vpc" })
}