resource "aws_sqs_queue" "dlq" {
  for_each = var.queues
  
  name = "${each.value}_error"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(var.tags, { Purpose = "dead-letter" })
}

resource "aws_sqs_queue" "main" {
  for_each = var.queues

  name                       = each.value
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = 345600 # 4 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags
}


resource "aws_sqs_queue_policy" "main" {
  for_each  = var.queues
  queue_url = aws_sqs_queue.main[each.key].url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIRSAAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.irsa_role_arn
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
        ]
        Resource = aws_sqs_queue.main[each.key].arn
      }
    ]
  })
}
