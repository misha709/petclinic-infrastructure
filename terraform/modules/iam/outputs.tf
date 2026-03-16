output "node_group_role_arn" {
  value       = try(aws_iam_role.node_group[0].arn, null)
  description = "ARN of the EKS node group IAM role"
}

output "node_group_instance_profile_name" {
  value       = try(aws_iam_instance_profile.node_group[0].name, null)
  description = "Name of the EC2 instance profile attached to worker nodes"
}

output "irsa_role_arn" {
  value       = try(aws_iam_role.irsa[0].arn, null)
  description = "ARN of the IRSA role — annotate the Kubernetes service account with this value"
}
