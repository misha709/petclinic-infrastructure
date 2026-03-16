module "sqs" {
  source = "../../modules/sqs"

  queues = toset([
    "petclinic-visit-created",
    "petclinic-visit-reminder-due",
  ])

  irsa_role_arn = module.irsa.irsa_role_arn

  tags = merge(var.project_tags, { Module = "sqs" })
}
