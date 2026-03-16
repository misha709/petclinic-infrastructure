output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "Full ECR repository URL for use in image references"
}

output "repository_name" {
  value       = aws_ecr_repository.this.name
  description = "ECR repository name"
}
