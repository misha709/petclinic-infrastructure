variable "name" {
  type        = string
  description = "ECR repository name (e.g. petclinic/owners)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to the repository"
  default     = {}
}
