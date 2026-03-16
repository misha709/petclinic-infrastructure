output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private_subnet : s.id]
  description = "List of private subnet IDs — passed to EKS cluster and node group"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public_subnet : s.id]
  description = "List of public subnet IDs"
}
