locals {
  cluster_name = "petclinic-dev"
}

# module "iam" {
#   source = "../../modules/iam"

#   cluster_name     = local.cluster_name
#   create_node_role = true
#   create_irsa_role = false

#   tags = merge(var.project_tags, { Module = "iam" })
# }

# module "eks" {
#   source = "../../modules/eks"

#   cluster_name       = local.cluster_name
#   private_subnet_ids = module.vpc.private_subnet_ids
#   node_role_arn      = module.iam.node_group_role_arn

#   tags = merge(var.project_tags, { Module = "eks" })
# }

# module "irsa" {
#   source = "../../modules/iam"

#   cluster_name         = local.cluster_name
#   create_node_role     = false
#   create_irsa_role     = true
#   oidc_issuer_url      = module.eks.oidc_issuer_url
#   oidc_provider_arn    = module.eks.oidc_provider_arn
#   irsa_namespace       = "petclinic"
#   irsa_service_account = "petclinic-sa"

#   tags = merge(var.project_tags, { Module = "iam" })
# }
