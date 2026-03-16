output "db_endpoint" {
  value       = aws_db_instance.main.address
  description = "RDS instance hostname (without port)"
}

output "db_port" {
  value       = aws_db_instance.main.port
  description = "PostgreSQL port"
}

output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "Name of the initial database"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "ARN of the Secrets Manager secret containing the full connection bundle"
}

output "security_group_id" {
  value       = aws_security_group.rds.id
  description = "ID of the RDS security group"
}
