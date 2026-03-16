variable "project_tags" {
  type = map(string)
  default = {
    "Project" = "petclinic"
    "Environment" = "dev"
  }
}