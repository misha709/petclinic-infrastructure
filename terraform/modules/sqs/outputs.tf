output "queue_urls" {
  value       = { for k, q in aws_sqs_queue.main : k => q.url }
  description = "Map of queue name → queue URL"
}

output "queue_arns" {
  value       = { for k, q in aws_sqs_queue.main : k => q.arn }
  description = "Map of queue name → queue ARN"
}

output "dlq_arns" {
  value       = { for k, q in aws_sqs_queue.dlq : k => q.arn }
  description = "Map of queue name → dead-letter queue ARN"
}
