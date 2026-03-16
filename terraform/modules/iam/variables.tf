variable "cluster_name" {
  type        = string
  description = "EKS cluster name — used to prefix all role and profile names"
}

variable "create_node_role" {
  type        = bool
  description = "Create the EKS node group IAM role and instance profile"
  default     = true
}

variable "create_irsa_role" {
  type        = bool
  description = "Create the IRSA pod role; requires oidc_issuer_url and oidc_provider_arn"
  default     = false
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL from the EKS cluster (required when create_irsa_role = true)"
  default     = null
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS OIDC IAM provider (required when create_irsa_role = true)"
  default     = null
}

variable "irsa_namespace" {
  type        = string
  description = "Kubernetes namespace the service account lives in"
  default     = "petclinic"
}

variable "irsa_service_account" {
  type        = string
  description = "Kubernetes service account name to bind the IRSA role to"
  default     = "petclinic-sa"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}
