variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.31"//TODO change to the latest version
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the EKS control plane and node group"
}

variable "node_role_arn" {
  type        = string
  description = "ARN of the IAM role to attach to worker nodes (from modules/iam)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}
