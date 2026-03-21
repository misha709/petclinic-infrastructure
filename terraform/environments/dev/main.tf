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

locals {
  cluster_name = "petclinic-dev"
}

module "iam" {
  source = "../../modules/iam"

  cluster_name     = local.cluster_name
  create_node_role = true
  create_irsa_role = false

  tags = merge(var.project_tags, { Module = "iam" })
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = local.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  node_role_arn      = module.iam.node_group_role_arn

  tags = merge(var.project_tags, { Module = "eks" })
}

module "irsa" {
  source = "../../modules/iam"

  cluster_name         = local.cluster_name
  create_node_role     = false
  create_irsa_role     = true
  oidc_issuer_url      = module.eks.oidc_issuer_url
  oidc_provider_arn    = module.eks.oidc_provider_arn
  irsa_namespace       = "petclinic"
  irsa_service_account = "petclinic-sa"

  tags = merge(var.project_tags, { Module = "iam" })
}


# module "rds" {
#   source = "../../modules/rds"

#   identifier                 = "petclinic-dev"
#   db_name                    = "petclinic"
#   username                   = "petclinic_admin"
#   private_subnet_ids         = module.vpc.private_subnet_ids
#   vpc_id                     = module.vpc.vpc_id
#   eks_node_security_group_id = module.eks.cluster_security_group_id

#   tags = merge(var.project_tags, { Module = "rds" })
# }

locals {
  ecr_services = toset([
    "petclinic/owners",
    "petclinic/pets",
    "petclinic/vets",
    "petclinic/visits",
    "petclinic/notifications",
    "petclinic/gateway",
  ])
}

module "ecr" {
  for_each = local.ecr_services
  source   = "../../modules/ecr"

  name = each.value
  tags = merge(var.project_tags, { Module = "ecr" })
}
