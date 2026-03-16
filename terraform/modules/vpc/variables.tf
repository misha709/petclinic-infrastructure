variable "vpc_cidr" {
  type        = string
  description = "A vpc CIDR"
}

variable "public_subnets" {
  type = map(object({
    cidr              = string
    availability_zone = string
  }))
  description = "Map of public subnets, each with a cidr and availability_zone"
}

variable "private_subnets" {
  type = map(object({
    cidr              = string
    availability_zone = string
  }))
  description = "Map of private subnets, each with a cidr and availability_zone"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name — used for kubernetes.io/cluster/<name> subnet auto-discovery tags"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources"
}
