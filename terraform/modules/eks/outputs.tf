output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS API server endpoint"
}

output "oidc_issuer_url" {
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
  description = "OIDC issuer URL — pass to modules/iam when creating the IRSA role"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "ARN of the EKS OIDC provider — pass to modules/iam when creating the IRSA role"
}
