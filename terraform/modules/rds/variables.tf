variable "identifier" {
  type        = string
  description = "Unique identifier for the RDS instance and related resources (e.g. petclinic-dev)"
}

variable "db_name" {
  type        = string
  description = "Name of the initial database created on the instance"
  default     = "petclinic"
}

variable "username" {
  type        = string
  description = "Master username for the PostgreSQL instance"
  default     = "petclinic_admin"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group — must span at least two AZs"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS security group will be created"
}

variable "eks_node_security_group_id" {
  type        = string
  description = "Security group ID of the EKS cluster nodes — granted ingress on port 5432"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}
