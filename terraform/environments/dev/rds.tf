module "rds" {
  source = "../../modules/rds"

  identifier                 = "petclinic-dev"
  db_name                    = "petclinic"
  username                   = "petclinic_admin"
  private_subnet_ids         = module.vpc.private_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  eks_node_security_group_id = module.eks.cluster_security_group_id

  tags = merge(var.project_tags, { Module = "rds" })
}
